const path = require("path");
const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// 정적 파일 제공 (public/index.html)
app.use(express.static(path.join(__dirname, "public")));

const PORT = Number(process.env.PORT || 3000);

// Day별 채점 규칙(체크리스트/연결어/콜로케이션) 가져오기
// GET /api/day_rules?grade=HighSchool_1&week=1&day=1
app.get("/api/day_rules", async (req, res) => {
  const grade = String(req.query.grade || "HighSchool_1");
  const week = Number(req.query.week || 1);
  const day = Number(req.query.day || 1);

// 학생 키로 student_id 확보 (없으면 생성)
app.post("/api/student", async (req, res) => {
  try {
    const student_key = String(req.body.student_key || "").trim();
    const display_name = String(req.body.display_name || "").trim();

    if (!student_key || !display_name) {
      return res.status(400).json({ error: "student_key and display_name required" });
    }

    // upsert
    await pool.query(
      `INSERT INTO students (student_key, display_name)
       VALUES (?, ?)
       ON DUPLICATE KEY UPDATE display_name=VALUES(display_name)`,
      [student_key, display_name]
    );

    const [rows] = await pool.query(
      `SELECT student_id, student_key, display_name FROM students WHERE student_key=? LIMIT 1`,
      [student_key]
    );

    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});

  try {
    // checklist 기본(최소 목표어휘/최소 문장/최소 단어수 등)
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

    // connectors (day_checklist_connectors)
    const conSql = `
      SELECT c.connector
      FROM days d
      JOIN day_checklists dc ON dc.day_id = d.day_id
      JOIN day_checklist_connectors c ON c.checklist_id = dc.checklist_id
      WHERE d.grade = ? AND d.week_no = ? AND d.day_no = ?
      ORDER BY c.connector
    `;
    const [conRows] = await pool.query(conSql, [grade, week, day]);

    // collocations (day_checklist_collocations)
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
    const connectors = conRows.map(r => r.connector);
    const collocations = colRows.map(r => r.collocation);

    res.json({ grade, week, day, checklist, connectors, collocations });
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});

// MySQL 풀
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT || 3306),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// 간단 헬스체크
app.get("/api/health", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT 1 AS ok");
    res.json({ ok: true, db: rows[0].ok });
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e.message || e) });
  }
});

/**
 * Day 학습세트 조회
 * GET /api/day?grade=HighSchool_1&week=1&day=1
 * -> v_day_learning_set 에서 root 10 + derived 3(미션)까지 가져옴
 */
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
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});

/**
 * 단어 카드 상세
 * GET /api/card?headword=effective&pos=adj
 * 또는 GET /api/card?word_id=123
 * -> v_word_learning_card 뷰 기반
 */
app.get("/api/card", async (req, res) => {
  const wordId = req.query.word_id ? Number(req.query.word_id) : null;
  const headword = req.query.headword ? String(req.query.headword) : null;
  const pos = req.query.pos ? String(req.query.pos) : null;

  try {
    let sql = "SELECT * FROM v_word_learning_card WHERE 1=1 ";
    const params = [];

    if (wordId) {
      sql += " AND word_id = ? ";
      params.push(wordId);
    } else {
      if (!headword || !pos) {
        return res.status(400).json({ error: "Provide word_id OR (headword and pos)." });
      }
      sql += " AND headword = ? AND pos = ? ";
      params.push(headword, pos);
    }

    const [rows] = await pool.query(sql, params);
    if (!rows.length) return res.status(404).json({ error: "Not found" });

    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});

// =============================
// Student + Attempts APIs
// =============================

// 학생 생성/업데이트
app.post("/api/student", async (req, res) => {
  try {
    const student_key = String(req.body.student_key || "").trim();
    const display_name = String(req.body.display_name || "").trim();

    if (!student_key || !display_name) {
      return res.status(400).json({ error: "student_key and display_name required" });
    }

    await pool.query(
      `INSERT INTO students (student_key, display_name)
       VALUES (?, ?)
       ON DUPLICATE KEY UPDATE display_name=VALUES(display_name)`,
      [student_key, display_name]
    );

    const [rows] = await pool.query(
      `SELECT student_id, student_key, display_name FROM students WHERE student_key=? LIMIT 1`,
      [student_key]
    );

    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});

// 말하기 기록 저장
app.post("/api/attempt", async (req, res) => {
  try {
    const b = req.body || {};
    const student_key = String(b.student_key || "").trim();
    const display_name = String(b.display_name || "").trim();

    const grade = String(b.grade || "HighSchool_1");
    const week_no = Number(b.week_no || 1);
    const day_no = Number(b.day_no || 1);

    const score = Number(b.score ?? 0);
    const vocab_hits = Number(b.vocab_hits ?? 0);
    const family_hits = Number(b.family_hits ?? 0);
    const connector_hits = Number(b.connector_hits ?? 0);
    const collocation_hits = Number(b.collocation_hits ?? 0);
    const word_count = Number(b.word_count ?? 0);
    const transcript = String(b.transcript || "");

    if (!student_key || !display_name) {
      return res.status(400).json({ error: "student_key and display_name required" });
    }

    // 학생 보장(없으면 생성)
    await pool.query(
      `INSERT INTO students (student_key, display_name)
       VALUES (?, ?)
       ON DUPLICATE KEY UPDATE display_name=VALUES(display_name)`,
      [student_key, display_name]
    );

    const [srows] = await pool.query(
      `SELECT student_id FROM students WHERE student_key=? LIMIT 1`,
      [student_key]
    );
    const student_id = srows[0].student_id;

    const [result] = await pool.query(
      `INSERT INTO speaking_attempts
        (student_id, grade, week_no, day_no, score, vocab_hits, family_hits, connector_hits, collocation_hits, word_count, transcript)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [student_id, grade, week_no, day_no, score, vocab_hits, family_hits, connector_hits, collocation_hits, word_count, transcript]
    );

    res.json({ ok: true, attempt_id: result.insertId });
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e.message || e) });
  }
});

// 학생 기록 조회(최근 N개)
app.get("/api/attempts", async (req, res) => {
  try {
    const student_key = String(req.query.student_key || "").trim();
    const limit = Math.min(200, Number(req.query.limit || 50));

    if (!student_key) return res.status(400).json({ error: "student_key required" });

    const [srows] = await pool.query(
      `SELECT student_id, student_key, display_name FROM students WHERE student_key=? LIMIT 1`,
      [student_key]
    );
    if (!srows.length) return res.json({ student: null, attempts: [] });

    const student = srows[0];

    const [rows] = await pool.query(
      `SELECT attempt_id, grade, week_no, day_no, score, vocab_hits, family_hits, connector_hits, collocation_hits, word_count, created_at
       FROM speaking_attempts
       WHERE student_id=?
       ORDER BY created_at DESC
       LIMIT ?`,
      [student.student_id, limit]
    );

    res.json({ student, attempts: rows });
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});

// Day의 root 단어들에 연결된 파생어(derived) 목록
// GET /api/day_family?grade=HighSchool_1&week=1&day=1
app.get("/api/day_family", async (req, res) => {
  const grade = String(req.query.grade || "HighSchool_1");
  const week = Number(req.query.week || 1);
  const day = Number(req.query.day || 1);

  try {
    const sql = `
      SELECT
        r.word_id   AS root_word_id,
        r.headword  AS root_headword,
        d.word_id   AS derived_word_id,
        d.headword  AS derived_headword
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
  } catch (e) {
    res.status(500).json({ error: String(e.message || e) });
  }
});



// index.html 라우팅(직접 접근 시)
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(PORT, () => {
  console.log(`✅ Server running: http://localhost:${PORT}`);
  console.log(`✅ Health:        http://localhost:${PORT}/api/health`);
  console.log(`✅ Day sample:    http://localhost:${PORT}/api/day?week=1&day=1`);
});