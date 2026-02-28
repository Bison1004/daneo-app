const path = require("path");
const express = require("express");
const cors = require("cors");
require("dotenv").config();

const pool = require("./db/pool");
const { requireAdminAuth } = require("./middleware/adminAuth");
const adminStudentsRoutes = require("./routes/adminStudentsRoutes");
const studentAccessRoutes = require("./routes/studentAccessRoutes");

const app = express();
const PORT = Number(process.env.PORT || 3000);

function isPlaceholder(value) {
  const normalized = String(value || "").trim().toLowerCase();
  if (!normalized) return true;
  return (
    normalized.includes("your_") ||
    normalized === "changeme" ||
    normalized === "example" ||
    normalized === "your_mysql_user" ||
    normalized === "your_mysql_password" ||
    normalized === "your_database_name"
  );
}

function getDbEnvValidation() {
  const requiredKeys = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"];
  const missingOrPlaceholder = requiredKeys.filter((key) => isPlaceholder(process.env[key]));

  return {
    ok: missingOrPlaceholder.length === 0,
    missingOrPlaceholder,
  };
}

app.use(cors());
app.use(express.json());

app.use("/api", studentAccessRoutes);
app.use("/api/admin", requireAdminAuth, adminStudentsRoutes);
app.use("/admin", requireAdminAuth);

app.use(express.static(path.join(__dirname, "public")));

app.get("/admin/students", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "admin", "students", "index.html"));
});

app.get("/admin/students/new", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "admin", "students", "new.html"));
});

app.get("/api/health", async (req, res) => {
  const envValidation = getDbEnvValidation();
  if (!envValidation.ok) {
    return res.status(500).json({
      ok: false,
      error: `DB 환경변수가 설정되지 않았습니다: ${envValidation.missingOrPlaceholder.join(", ")}`,
      hint: ".env 파일에서 DB_HOST, DB_USER, DB_PASSWORD, DB_NAME 값을 실제 MySQL 정보로 입력하세요.",
    });
  }

  try {
    const [rows] = await pool.query("SELECT 1 AS ok");
    res.json({ ok: true, db: rows[0].ok });
  } catch (error) {
    res.status(500).json({ ok: false, error: String(error.message || error) });
  }
});

app.get("/api/day_rules", async (req, res) => {
  const grade = String(req.query.grade || "HighSchool_1");
  const week = Number(req.query.week || 1);
  const day = Number(req.query.day || 1);

  try {
    const chkSql = `
      SELECT
        dc.checklist_id,
        dc.target_hits_min,
        dc.target_hits_max,
        dc.points_vocab,
        dc.family_bonus_on,
        dc.points_family,
        dc.min_words,
        dc.min_sentences
      FROM days d
      JOIN day_checklists dc ON dc.day_id = d.day_id
      WHERE d.grade = ? AND d.week_no = ? AND d.day_no = ?
      LIMIT 1
    `;
    const [chkRows] = await pool.query(chkSql, [grade, week, day]);

    const conSql = `
      SELECT c.connector
      FROM days d
      JOIN day_checklists dc ON dc.day_id = d.day_id
      JOIN day_checklist_connectors c ON c.checklist_id = dc.checklist_id
      WHERE d.grade = ? AND d.week_no = ? AND d.day_no = ?
      ORDER BY c.connector
    `;
    const [conRows] = await pool.query(conSql, [grade, week, day]);

    const colSql = `
      SELECT c.collocation
      FROM days d
      JOIN day_checklists dc ON dc.day_id = d.day_id
      JOIN day_checklist_collocations c ON c.checklist_id = dc.checklist_id
      WHERE d.grade = ? AND d.week_no = ? AND d.day_no = ?
      ORDER BY c.collocation
    `;
    const [colRows] = await pool.query(colSql, [grade, week, day]);

    const checklist = chkRows[0] || null;
    const connectors = conRows.map((row) => row.connector);
    const collocations = colRows.map((row) => row.collocation);

    res.json({ grade, week, day, checklist, connectors, collocations });
  } catch (error) {
    res.status(500).json({ error: String(error.message || error) });
  }
});

app.get("/api/day", async (req, res) => {
  const grade = String(req.query.grade || "HighSchool_1");
  const week = Number(req.query.week || 1);
  const day = Number(req.query.day || 1);

  try {
    const sql = `
      SELECT *
      FROM v_day_learning_set
      WHERE grade = ? AND week_no = ? AND day_no = ?
      ORDER BY sort_no
    `;
    const [rows] = await pool.query(sql, [grade, week, day]);
    res.json({ grade, week, day, items: rows });
  } catch (error) {
    res.status(500).json({ error: String(error.message || error) });
  }
});

app.get("/api/card", async (req, res) => {
  const wordId = req.query.word_id ? Number(req.query.word_id) : null;
  const headword = req.query.headword ? String(req.query.headword) : null;
  const pos = req.query.pos ? String(req.query.pos) : null;

  try {
    let sql = "SELECT * FROM v_word_learning_card WHERE 1=1";
    const params = [];

    if (wordId) {
      sql += " AND word_id = ?";
      params.push(wordId);
    } else {
      if (!headword || !pos) {
        return res.status(400).json({ error: "Provide word_id OR (headword and pos)." });
      }
      sql += " AND headword = ? AND pos = ?";
      params.push(headword, pos);
    }

    const [rows] = await pool.query(sql, params);
    if (!rows.length) {
      return res.status(404).json({ error: "Not found" });
    }

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: String(error.message || error) });
  }
});

app.post("/api/student", async (req, res) => {
  try {
    const student_key = String(req.body.student_key || "").trim();
    const student_name = String(req.body.student_name || req.body.display_name || "").trim();

    if (!student_key) {
      return res.status(400).json({ error: "student_key required" });
    }

    const [rows] = await pool.query(
      `
      SELECT student_id, student_key, student_name, status
      FROM students
      WHERE student_key = ?
      LIMIT 1
      `,
      [student_key]
    );

    if (!rows.length) {
      return res.status(404).json({ error: "등록되지 않은 학생 키입니다." });
    }

    const student = rows[0];
    if (student.status !== "active") {
      return res.status(403).json({ error: "비활성화된 학생 키입니다." });
    }

    if (student_name && student_name !== student.student_name) {
      await pool.query(
        `
        UPDATE students
        SET student_name = ?, updated_at = CURRENT_TIMESTAMP
        WHERE student_id = ?
        `,
        [student_name, student.student_id]
      );
      student.student_name = student_name;
    }

    res.json({ ...student, display_name: student.student_name });
  } catch (error) {
    res.status(500).json({ error: String(error.message || error) });
  }
});

app.post("/api/attempt", async (req, res) => {
  try {
    const payload = req.body || {};
    const student_key = String(payload.student_key || "").trim();
    const student_name = String(payload.student_name || payload.display_name || "").trim();

    const grade = String(payload.grade || "HighSchool_1");
    const week_no = Number(payload.week_no || 1);
    const day_no = Number(payload.day_no || 1);

    const score = Number(payload.score ?? 0);
    const vocab_hits = Number(payload.vocab_hits ?? 0);
    const family_hits = Number(payload.family_hits ?? 0);
    const connector_hits = Number(payload.connector_hits ?? 0);
    const collocation_hits = Number(payload.collocation_hits ?? 0);
    const word_count = Number(payload.word_count ?? 0);
    const transcript = String(payload.transcript || "");

    if (!student_key || !student_name) {
      return res.status(400).json({ error: "student_key and student_name required" });
    }

    const [studentRows] = await pool.query(
      `SELECT student_id, status FROM students WHERE student_key = ? LIMIT 1`,
      [student_key]
    );

    if (!studentRows.length) {
      return res.status(404).json({ ok: false, error: "등록되지 않은 학생 키입니다." });
    }

    if (studentRows[0].status !== "active") {
      return res.status(403).json({ ok: false, error: "비활성화된 학생 키입니다." });
    }

    const student_id = studentRows[0].student_id;

    await pool.query(
      `
      UPDATE students
      SET student_name = ?, updated_at = CURRENT_TIMESTAMP
      WHERE student_id = ?
      `,
      [student_name, student_id]
    );

    const [result] = await pool.query(
      `
      INSERT INTO speaking_attempts
        (student_id, grade, week_no, day_no, score, vocab_hits, family_hits, connector_hits, collocation_hits, word_count, transcript)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        student_id,
        grade,
        week_no,
        day_no,
        score,
        vocab_hits,
        family_hits,
        connector_hits,
        collocation_hits,
        word_count,
        transcript,
      ]
    );

    res.json({ ok: true, attempt_id: result.insertId });
  } catch (error) {
    res.status(500).json({ ok: false, error: String(error.message || error) });
  }
});

app.get("/api/attempts", async (req, res) => {
  try {
    const student_key = String(req.query.student_key || "").trim();
    const limit = Math.min(200, Number(req.query.limit || 50));

    if (!student_key) {
      return res.status(400).json({ error: "student_key required" });
    }

    const [studentRows] = await pool.query(
      `
      SELECT student_id, student_key, student_name, status
      FROM students
      WHERE student_key = ?
      LIMIT 1
      `,
      [student_key]
    );

    if (!studentRows.length) {
      return res.json({ student: null, attempts: [] });
    }

    const student = {
      ...studentRows[0],
      display_name: studentRows[0].student_name,
    };

    const [attemptRows] = await pool.query(
      `
      SELECT
        attempt_id,
        grade,
        week_no,
        day_no,
        score,
        vocab_hits,
        family_hits,
        connector_hits,
        collocation_hits,
        word_count,
        created_at
      FROM speaking_attempts
      WHERE student_id = ?
      ORDER BY created_at DESC
      LIMIT ?
      `,
      [student.student_id, limit]
    );

    res.json({ student, attempts: attemptRows });
  } catch (error) {
    res.status(500).json({ error: String(error.message || error) });
  }
});

app.get("/api/day_family", async (req, res) => {
  const grade = String(req.query.grade || "HighSchool_1");
  const week = Number(req.query.week || 1);
  const day = Number(req.query.day || 1);

  try {
    const sql = `
      SELECT
        r.word_id AS root_word_id,
        r.headword AS root_headword,
        d.word_id AS derived_word_id,
        d.headword AS derived_headword
      FROM days dy
      JOIN day_words dw ON dw.day_id = dy.day_id
      JOIN words r ON r.word_id = dw.word_id
      JOIN word_family_edges e ON e.root_word_id = r.word_id
      JOIN words d ON d.word_id = e.derived_word_id
      WHERE dy.grade = ? AND dy.week_no = ? AND dy.day_no = ?
      ORDER BY r.headword, d.headword
    `;

    const [rows] = await pool.query(sql, [grade, week, day]);
    res.json({ grade, week, day, rows });
  } catch (error) {
    res.status(500).json({ error: String(error.message || error) });
  }
});

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(PORT, () => {
  const envValidation = getDbEnvValidation();
  console.log(`✅ Server running: http://localhost:${PORT}`);
  console.log(`✅ Health:        http://localhost:${PORT}/api/health`);
  console.log(`✅ Day sample:    http://localhost:${PORT}/api/day?week=1&day=1`);
  console.log(`✅ Admin list:    http://localhost:${PORT}/admin/students`);
  if (!envValidation.ok) {
    console.warn(
      `⚠️  DB 환경변수 미설정/템플릿값 감지: ${envValidation.missingOrPlaceholder.join(", ")}`
    );
    console.warn("⚠️  .env에 실제 MySQL 정보를 입력해야 /api/* DB 기능이 정상 동작합니다.");
  }
});
