const fs = require("fs");
const path = require("path");
const mysql = require("mysql2/promise");
require("dotenv").config();

const RULE_MAP = {
  rule_frequency: "FREQUENCY",
  rule_utility: "UTILITY",
  rule_core_meaning: "CORE_MEANING",
  rule_collocation: "COLLOCATION",
  rule_word_family: "WORD_FAMILY",
  rule_confusion_risk: "CONFUSION_RISK",
};

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

function validateDbEnv() {
  const required = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"];
  const invalid = required.filter((key) => isPlaceholder(process.env[key]));
  if (invalid.length > 0) {
    throw new Error(
      `DB 환경변수가 설정되지 않았습니다: ${invalid.join(", ")} (.env 파일을 먼저 설정하세요)`
    );
  }
}

function parseCsvLine(line) {
  const values = [];
  let current = "";
  let inQuotes = false;

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    const next = line[index + 1];

    if (char === '"') {
      if (inQuotes && next === '"') {
        current += '"';
        index += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char === "," && !inQuotes) {
      values.push(current);
      current = "";
      continue;
    }

    current += char;
  }

  values.push(current);
  return values.map((value) => value.trim());
}

function parseCsv(content) {
  const normalized = content.replace(/^\uFEFF/, "").replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  const lines = normalized
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0);

  if (lines.length < 2) {
    return [];
  }

  const headers = parseCsvLine(lines[0]);
  const rows = [];

  for (let i = 1; i < lines.length; i += 1) {
    const values = parseCsvLine(lines[i]);
    const row = {};
    headers.forEach((header, idx) => {
      row[header] = values[idx] ?? "";
    });
    rows.push(row);
  }

  return rows;
}

function asInt(value, fallback = null) {
  if (value === undefined || value === null || value === "") return fallback;
  const numberValue = Number(value);
  if (!Number.isFinite(numberValue)) return fallback;
  return Math.trunc(numberValue);
}

function asText(value) {
  return String(value || "").trim();
}

function asRulePass(value) {
  return asText(value).toLowerCase() !== "fail";
}

async function upsertTrack(connection, trackName) {
  const normalizedTrackName = asText(trackName);
  if (!normalizedTrackName) {
    throw new Error("track_name is required");
  }

  const [trackRows] = await connection.query(
    `SELECT track_id FROM wb_tracks WHERE track_name = ? LIMIT 1`,
    [normalizedTrackName]
  );

  if (trackRows.length > 0) {
    return trackRows[0].track_id;
  }

  const [insertResult] = await connection.query(
    `
    INSERT INTO wb_tracks
      (track_name, target_grade, cefr_band_min, cefr_band_max, actfl_band_min, actfl_band_max, days_total)
    VALUES (?, '고1', 'A2', 'B1+', 'Novice High', 'Intermediate Mid', 365)
    `,
    [normalizedTrackName]
  );

  return insertResult.insertId;
}

async function upsertDay(connection, trackId, row) {
  const dayNo = asInt(row.day_no);
  if (!dayNo) {
    throw new Error(`day_no is required (track=${row.track_name || ""})`);
  }

  const theme = asText(row.theme) || `Day ${dayNo}`;
  const cefrTag = asText(row.cefr_tag) || "B1";
  const actflTag = asText(row.actfl_tag) || "Intermediate Mid";
  const notes = asText(row.notes);

  await connection.query(
    `
    INSERT INTO wb_days (track_id, day_no, theme, cefr_tag, actfl_tag, notes)
    VALUES (?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      theme = VALUES(theme),
      cefr_tag = VALUES(cefr_tag),
      actfl_tag = VALUES(actfl_tag),
      notes = VALUES(notes),
      updated_at = CURRENT_TIMESTAMP
    `,
    [trackId, dayNo, theme, cefrTag, actflTag, notes]
  );

  const [dayRows] = await connection.query(
    `SELECT day_id FROM wb_days WHERE track_id = ? AND day_no = ? LIMIT 1`,
    [trackId, dayNo]
  );

  return dayRows[0].day_id;
}

async function upsertLexeme(connection, row) {
  const headword = asText(row.headword);
  const pos = asText(row.pos);

  if (!headword || !pos) {
    return null;
  }

  const values = {
    headword,
    ipa_us: asText(row.ipa_us),
    ipa_uk: asText(row.ipa_uk),
    pos,
    core_meaning_en: asText(row.core_meaning_en) || `${headword} core meaning`,
    core_meaning_ko: asText(row.core_meaning_ko),
    cefr_tag: asText(row.cefr_tag) || "B1",
    actfl_tag: asText(row.actfl_tag) || "Intermediate Mid",
    utility_priority: ["high", "medium", "low"].includes(asText(row["utility_priority(high|medium|low)"]).toLowerCase())
      ? asText(row["utility_priority(high|medium|low)"]).toLowerCase()
      : "medium",
  };

  await connection.query(
    `
    INSERT INTO wb_lexemes
      (headword, ipa_us, ipa_uk, pos, core_meaning_en, core_meaning_ko, cefr_tag, actfl_tag, utility_priority)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      ipa_us = VALUES(ipa_us),
      ipa_uk = VALUES(ipa_uk),
      core_meaning_en = VALUES(core_meaning_en),
      core_meaning_ko = VALUES(core_meaning_ko),
      cefr_tag = VALUES(cefr_tag),
      actfl_tag = VALUES(actfl_tag),
      utility_priority = VALUES(utility_priority),
      is_active = 1,
      updated_at = CURRENT_TIMESTAMP
    `,
    [
      values.headword,
      values.ipa_us,
      values.ipa_uk,
      values.pos,
      values.core_meaning_en,
      values.core_meaning_ko,
      values.cefr_tag,
      values.actfl_tag,
      values.utility_priority,
    ]
  );

  const [rows] = await connection.query(
    `SELECT lexeme_id FROM wb_lexemes WHERE headword = ? AND pos = ? LIMIT 1`,
    [headword, pos]
  );

  return rows[0].lexeme_id;
}

async function upsertCollocation(connection, lexemeId, row) {
  const collocation = asText(row.collocation_1);
  if (!collocation) return false;

  await connection.query(
    `
    INSERT INTO wb_collocations (lexeme_id, collocation, sort_no)
    VALUES (?, ?, 1)
    ON DUPLICATE KEY UPDATE sort_no = VALUES(sort_no)
    `,
    [lexemeId, collocation]
  );

  return true;
}

async function upsertExample(connection, lexemeId, row) {
  const sentence = asText(row.example_sentence_1);
  if (!sentence) return false;

  await connection.query(
    `
    INSERT INTO wb_examples (lexeme_id, sentence, sentence_ko, sort_no)
    VALUES (?, ?, ?, 1)
    ON DUPLICATE KEY UPDATE
      sentence_ko = VALUES(sentence_ko),
      sort_no = VALUES(sort_no)
    `,
    [lexemeId, sentence, asText(row.example_sentence_ko_1)]
  );

  return true;
}

async function upsertDerivatives(connection, lexemeId, row) {
  let count = 0;

  for (let index = 1; index <= 3; index += 1) {
    const word = asText(row[`derivative_${index}_word`]);
    const derivativePos = asText(row[`derivative_${index}_pos`]);

    if (!word || !derivativePos) continue;

    await connection.query(
      `
      INSERT INTO wb_derivatives (lexeme_id, derivative_word, derivative_pos, note, sort_no)
      VALUES (?, ?, ?, '', ?)
      ON DUPLICATE KEY UPDATE
        sort_no = VALUES(sort_no),
        note = VALUES(note)
      `,
      [lexemeId, word, derivativePos, index]
    );

    count += 1;
  }

  return count;
}

async function upsertDayItem(connection, dayId, lexemeId, sortNo) {
  await connection.query(
    `
    INSERT INTO wb_day_items (day_id, lexeme_id, sort_no, is_required)
    VALUES (?, ?, ?, 1)
    ON DUPLICATE KEY UPDATE
      sort_no = VALUES(sort_no),
      is_required = VALUES(is_required)
    `,
    [dayId, lexemeId, sortNo]
  );

  const [rows] = await connection.query(
    `SELECT day_item_id FROM wb_day_items WHERE day_id = ? AND lexeme_id = ? LIMIT 1`,
    [dayId, lexemeId]
  );

  return rows[0].day_item_id;
}

async function upsertRuleChecks(connection, dayItemId, row, reviewerNote) {
  let checks = 0;

  for (const [columnName, ruleCode] of Object.entries(RULE_MAP)) {
    await connection.query(
      `
      INSERT INTO wb_day_item_rule_checks (day_item_id, rule_code, passed, reviewer_note)
      VALUES (?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        passed = VALUES(passed),
        reviewer_note = VALUES(reviewer_note),
        reviewed_at = CURRENT_TIMESTAMP
      `,
      [dayItemId, ruleCode, asRulePass(row[columnName]) ? 1 : 0, reviewerNote]
    );

    checks += 1;
  }

  return checks;
}

async function upsertConfusingPair(connection, lexemeId, row) {
  const pairWord = asText(row["confusion_pair_word(optional)"]);
  const pairReason = asText(row["confusion_pair_reason(optional)"]);

  if (!pairWord) return false;

  const [pairRows] = await connection.query(
    `SELECT lexeme_id FROM wb_lexemes WHERE headword = ? ORDER BY lexeme_id DESC LIMIT 1`,
    [pairWord]
  );

  if (!pairRows.length) {
    return false;
  }

  const pairLexemeId = pairRows[0].lexeme_id;
  if (pairLexemeId === lexemeId) return false;

  const minId = Math.min(lexemeId, pairLexemeId);
  const maxId = Math.max(lexemeId, pairLexemeId);

  await connection.query(
    `
    INSERT INTO wb_confusing_pairs (lexeme_id_a, lexeme_id_b, reason)
    VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE reason = VALUES(reason)
    `,
    [minId, maxId, pairReason]
  );

  return true;
}

async function run() {
  validateDbEnv();

  const dayPlanPath = process.argv[2]
    ? path.resolve(process.argv[2])
    : path.resolve("wordbook_templates/day_plan_2_30.csv");
  const dayItemsPath = process.argv[3]
    ? path.resolve(process.argv[3])
    : path.resolve("wordbook_templates/day_items_2_30.csv");

  if (!fs.existsSync(dayPlanPath)) {
    throw new Error(`CSV not found: ${dayPlanPath}`);
  }
  if (!fs.existsSync(dayItemsPath)) {
    throw new Error(`CSV not found: ${dayItemsPath}`);
  }

  const dayPlanRows = parseCsv(fs.readFileSync(dayPlanPath, "utf8"));
  const dayItemRows = parseCsv(fs.readFileSync(dayItemsPath, "utf8"));

  if (!dayPlanRows.length) {
    throw new Error("day_plan csv is empty");
  }

  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    charset: "utf8mb4",
  });

  const dayCache = new Map();
  const trackCache = new Map();
  const stats = {
    days: 0,
    lexemes: 0,
    dayItems: 0,
    derivatives: 0,
    collocations: 0,
    examples: 0,
    ruleChecks: 0,
    confusingPairs: 0,
    skippedRows: 0,
  };

  try {
    await connection.beginTransaction();

    for (const row of dayPlanRows) {
      const trackName = asText(row.track_name);
      const dayNo = asInt(row.day_no);
      if (!trackName || !dayNo) continue;

      let trackId = trackCache.get(trackName);
      if (!trackId) {
        trackId = await upsertTrack(connection, trackName);
        trackCache.set(trackName, trackId);
      }

      const dayId = await upsertDay(connection, trackId, row);
      dayCache.set(`${trackName}:${dayNo}`, dayId);
      stats.days += 1;
    }

    for (const row of dayItemRows) {
      const trackName = asText(row.track_name);
      const dayNo = asInt(row.day_no);
      const sortNo = asInt(row.sort_no);
      const headword = asText(row.headword);
      const pos = asText(row.pos);

      if (!trackName || !dayNo || !sortNo || !headword || !pos) {
        stats.skippedRows += 1;
        continue;
      }

      const dayKey = `${trackName}:${dayNo}`;
      const dayId = dayCache.get(dayKey);
      if (!dayId) {
        throw new Error(`day not found in day_plan csv: ${dayKey}`);
      }

      const lexemeId = await upsertLexeme(connection, row);
      if (!lexemeId) {
        stats.skippedRows += 1;
        continue;
      }

      stats.lexemes += 1;

      const dayItemId = await upsertDayItem(connection, dayId, lexemeId, sortNo);
      stats.dayItems += 1;

      if (await upsertCollocation(connection, lexemeId, row)) {
        stats.collocations += 1;
      }
      if (await upsertExample(connection, lexemeId, row)) {
        stats.examples += 1;
      }

      stats.derivatives += await upsertDerivatives(connection, lexemeId, row);

      const reviewerNote = asText(row.reviewer_note);
      stats.ruleChecks += await upsertRuleChecks(connection, dayItemId, row, reviewerNote);

      if (await upsertConfusingPair(connection, lexemeId, row)) {
        stats.confusingPairs += 1;
      }
    }

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    await connection.end();
  }

  console.log("Import completed ✅");
  console.log(`day rows processed: ${stats.days}`);
  console.log(`lexemes upserted: ${stats.lexemes}`);
  console.log(`day items upserted: ${stats.dayItems}`);
  console.log(`derivatives upserted: ${stats.derivatives}`);
  console.log(`collocations upserted: ${stats.collocations}`);
  console.log(`examples upserted: ${stats.examples}`);
  console.log(`rule checks upserted: ${stats.ruleChecks}`);
  console.log(`confusing pairs upserted: ${stats.confusingPairs}`);
  console.log(`rows skipped(blank core fields): ${stats.skippedRows}`);
}

run().catch((error) => {
  console.error(`Import failed: ${error.message}`);
  process.exit(1);
});
