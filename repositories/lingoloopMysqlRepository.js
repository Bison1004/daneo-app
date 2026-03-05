const pool = require("../db/pool");

let initialized = false;

function parseJson(value, fallback) {
  if (value == null || value === "") return fallback;
  try {
    return JSON.parse(value);
  } catch (_) {
    return fallback;
  }
}

async function ensureSchema() {
  if (initialized) return;

  await pool.query(`
    CREATE TABLE IF NOT EXISTS lingoloop_words (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(64) NOT NULL,
      word VARCHAR(120) NOT NULL,
      translation VARCHAR(255) NOT NULL,
      examples_json JSON NULL,
      tags_json JSON NULL,
      ease_factor DECIMAL(4,2) NOT NULL DEFAULT 2.50,
      interval_days INT NOT NULL DEFAULT 0,
      repetitions INT NOT NULL DEFAULT 0,
      next_review DATETIME NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_ll_words_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS lingoloop_reviews (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(64) NOT NULL,
      word_id BIGINT NOT NULL,
      grade INT NOT NULL,
      source VARCHAR(32) NOT NULL DEFAULT 'quiz',
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_ll_reviews_user (user_id),
      INDEX idx_ll_reviews_word (word_id),
      CONSTRAINT fk_ll_reviews_word FOREIGN KEY (word_id)
        REFERENCES lingoloop_words(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS lingoloop_speech_logs (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(64) NOT NULL,
      overall INT NOT NULL,
      matched_words_json JSON NULL,
      missed_words_json JSON NULL,
      feedback VARCHAR(500) NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_ll_speech_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS lingoloop_chat_logs (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(64) NOT NULL,
      provider VARCHAR(32) NOT NULL DEFAULT 'mock',
      messages_json JSON NULL,
      response_text TEXT NOT NULL,
      corrections_json JSON NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_ll_chat_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  // Backward-compatible migration for early prototypes.
  await pool.query("ALTER TABLE lingoloop_words ADD COLUMN IF NOT EXISTS user_id VARCHAR(64) NOT NULL DEFAULT 'public'");
  await pool.query("ALTER TABLE lingoloop_reviews ADD COLUMN IF NOT EXISTS user_id VARCHAR(64) NOT NULL DEFAULT 'public'");
  await pool.query("ALTER TABLE lingoloop_speech_logs ADD COLUMN IF NOT EXISTS user_id VARCHAR(64) NOT NULL DEFAULT 'public'");
  await pool.query("ALTER TABLE lingoloop_chat_logs ADD COLUMN IF NOT EXISTS user_id VARCHAR(64) NOT NULL DEFAULT 'public'");

  initialized = true;
}

function mapWordRow(row) {
  return {
    id: String(row.id),
    userId: String(row.user_id),
    word: row.word,
    translation: row.translation,
    examples: parseJson(row.examples_json, []),
    tags: parseJson(row.tags_json, []),
    easeFactor: Number(row.ease_factor),
    interval: Number(row.interval_days),
    repetitions: Number(row.repetitions),
    nextReview: new Date(row.next_review),
    createdAt: row.created_at ? new Date(row.created_at) : null,
  };
}

async function createWord(userId, input) {
  await ensureSchema();

  const now = new Date();
  const [result] = await pool.query(
    `
    INSERT INTO lingoloop_words
      (user_id, word, translation, examples_json, tags_json, ease_factor, interval_days, repetitions, next_review)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `,
    [
      String(userId),
      String(input.word || "").trim(),
      String(input.translation || "").trim(),
      JSON.stringify(Array.isArray(input.examples) ? input.examples.slice(0, 3) : []),
      JSON.stringify(Array.isArray(input.tags) ? input.tags : []),
      2.5,
      0,
      0,
      now,
    ]
  );

  return getWordById(userId, result.insertId);
}

async function getWordById(userId, id) {
  await ensureSchema();

  const [rows] = await pool.query("SELECT * FROM lingoloop_words WHERE user_id = ? AND id = ? LIMIT 1", [String(userId), Number(id)]);
  if (!rows.length) return null;
  return mapWordRow(rows[0]);
}

async function replaceWord(userId, id, updatedWord) {
  await ensureSchema();

  await pool.query(
    `
    UPDATE lingoloop_words
    SET ease_factor = ?, interval_days = ?, repetitions = ?, next_review = ?
    WHERE user_id = ? AND id = ?
    `,
    [
      Number(updatedWord.easeFactor || 2.5),
      Number(updatedWord.interval || 0),
      Number(updatedWord.repetitions || 0),
      updatedWord.nextReview || new Date(),
      String(userId),
      Number(id),
    ]
  );

  return getWordById(userId, id);
}

async function addReview(userId, log) {
  await ensureSchema();

  await pool.query(
    "INSERT INTO lingoloop_reviews (user_id, word_id, grade, source) VALUES (?, ?, ?, ?)",
    [String(userId), Number(log.wordId), Number(log.grade || 0), String(log.source || "quiz")]
  );
}

async function addSpeechLog(userId, log) {
  await ensureSchema();

  await pool.query(
    `
    INSERT INTO lingoloop_speech_logs (user_id, overall, matched_words_json, missed_words_json, feedback)
    VALUES (?, ?, ?, ?, ?)
    `,
    [
      String(userId),
      Number(log.overall || 0),
      JSON.stringify(Array.isArray(log.matchedWords) ? log.matchedWords : []),
      JSON.stringify(Array.isArray(log.missedWords) ? log.missedWords : []),
      String(log.feedback || ""),
    ]
  );
}

async function addChatLog(userId, log) {
  await ensureSchema();

  await pool.query(
    `
    INSERT INTO lingoloop_chat_logs (user_id, provider, messages_json, response_text, corrections_json)
    VALUES (?, ?, ?, ?, ?)
    `,
    [
      String(userId),
      String(log.provider || "mock"),
      JSON.stringify(Array.isArray(log.messages) ? log.messages : []),
      String(log.responseText || ""),
      JSON.stringify(Array.isArray(log.corrections) ? log.corrections : []),
    ]
  );
}

async function listWords(userId) {
  await ensureSchema();

  const [rows] = await pool.query("SELECT * FROM lingoloop_words WHERE user_id = ? ORDER BY created_at DESC", [String(userId)]);
  return rows.map(mapWordRow);
}

async function getProgressSnapshot(userId) {
  await ensureSchema();

  const [words] = await pool.query("SELECT * FROM lingoloop_words WHERE user_id = ?", [String(userId)]);
  const [reviews] = await pool.query("SELECT grade, source, created_at FROM lingoloop_reviews WHERE user_id = ?", [String(userId)]);
  const [speechLogs] = await pool.query("SELECT overall, created_at FROM lingoloop_speech_logs WHERE user_id = ?", [String(userId)]);
  const [chatLogs] = await pool.query("SELECT provider, created_at FROM lingoloop_chat_logs WHERE user_id = ?", [String(userId)]);

  return {
    words: words.map(mapWordRow),
    reviews: reviews.map((row) => ({
      grade: Number(row.grade),
      source: row.source,
      createdAt: row.created_at ? new Date(row.created_at) : null,
    })),
    speechLogs: speechLogs.map((row) => ({
      overall: Number(row.overall),
      createdAt: row.created_at ? new Date(row.created_at) : null,
    })),
    chatLogs: chatLogs.map((row) => ({
      provider: row.provider,
      createdAt: row.created_at ? new Date(row.created_at) : null,
    })),
  };
}

module.exports = {
  createWord,
  getWordById,
  replaceWord,
  addReview,
  addSpeechLog,
  addChatLog,
  listWords,
  getProgressSnapshot,
  ensureSchema,
};
