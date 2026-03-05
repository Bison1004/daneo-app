const repository = require("../repositories/lingoloopRepository");
const { reviewCard, getDueCards, getNewCards, calculateStudySession } = require("../lib/lingoloop/srsEngine");
const { scorePronunciation } = require("../lib/lingoloop/speechScorer");
const { summarizeProgress } = require("../lib/lingoloop/progressTracker");
const { generateClaudeChat } = require("../lib/lingoloop/claudeClient");
const { buildQuizQuestion, gradeQuiz } = require("../lib/lingoloop/quizEngine");

function getUserId(req) {
  return String(req.lingoloopUser?.userId || "public");
}

function buildExamples(word, translation) {
  return [
    `I reviewed the word ${word} this morning.`,
    `Can you use ${word} in a sentence?`,
    `In Korean, ${word} can mean ${translation}.`,
  ];
}

function normalizeType(value) {
  const type = String(value || "due").toLowerCase();
  return ["due", "new", "all"].includes(type) ? type : "due";
}

function shouldStream(req) {
  const queryStream = String(req.query.stream || "").toLowerCase() === "true";
  const accept = String(req.headers.accept || "").toLowerCase();
  return queryStream || accept.includes("text/event-stream");
}

function sendSse(res, payload) {
  res.write(`data: ${JSON.stringify(payload)}\n\n`);
}

function streamResponse(res, text, meta) {
  const chunks = String(text || "")
    .split(/(?<=[.!?])\s+/)
    .filter(Boolean);

  chunks.forEach((chunk) => {
    sendSse(res, { content: chunk });
  });

  sendSse(res, { done: true, ...meta });
  res.end();
}

async function listWords(req, res) {
  const userId = getUserId(req);
  const type = normalizeType(req.query.type);
  const limit = Math.max(1, Math.min(100, Number(req.query.limit || 50)));

  const words = await repository.listWords(userId);
  let cards = words;
  if (type === "due") cards = getDueCards(words, new Date(), limit);
  if (type === "new") cards = getNewCards(words, limit);
  if (type === "all") cards = words.slice(0, limit);

  return res.json({
    cards,
    stats: {
      dueCount: getDueCards(words).length,
      newCount: getNewCards(words).length,
      session: calculateStudySession(words),
    },
  });
}

async function createWord(req, res) {
  const userId = getUserId(req);
  const word = String(req.body.word || "").trim();
  const translation = String(req.body.translation || "").trim();

  if (!word || !translation) {
    return res.status(400).json({ error: "word and translation are required" });
  }

  const created = await repository.createWord(userId, {
    word,
    translation,
    tags: Array.isArray(req.body.tags) ? req.body.tags : [],
    examples: buildExamples(word, translation),
  });

  return res.status(201).json(created);
}

async function updateReview(req, res) {
  const userId = getUserId(req);
  const id = String(req.params.id || "").trim();
  const grade = Number(req.body.grade);
  const source = String(req.body.source || "quiz").trim();

  const existing = await repository.getWordById(userId, id);
  if (!existing) {
    return res.status(404).json({ error: "word not found" });
  }

  if (Number.isNaN(grade) || grade < 0 || grade > 5) {
    return res.status(400).json({ error: "grade must be between 0 and 5" });
  }

  const updated = reviewCard(existing, grade, new Date());
  await repository.replaceWord(userId, id, updated);
  await repository.addReview(userId, { wordId: id, grade, source });

  return res.json({
    interval: updated.interval,
    easeFactor: updated.easeFactor,
    nextReview: updated.nextReview,
    repetitions: updated.repetitions,
  });
}

async function speechScore(req, res) {
  const userId = getUserId(req);
  const spokenText = String(req.body.spokenText || "").trim();
  const targetText = String(req.body.targetText || "").trim();
  const confidence = Number(req.body.confidence ?? 0.5);

  if (!spokenText || !targetText) {
    return res.status(400).json({ error: "spokenText and targetText are required" });
  }

  const scored = scorePronunciation(spokenText, targetText, confidence);
  await repository.addSpeechLog(userId, scored);
  return res.json(scored);
}

async function chat(req, res) {
  const userId = getUserId(req);
  const messages = Array.isArray(req.body.messages) ? req.body.messages : [];
  const targetWords = Array.isArray(req.body.targetWords) ? req.body.targetWords : [];
  const level = String(req.body.level || "A2").trim();
  const scenario = String(req.body.scenario || "").trim();

  const userText = messages
    .filter((item) => item && item.role === "user")
    .map((item) => String(item.content || "").trim())
    .filter(Boolean)
    .join(" ");

  const fallbackText = targetWords.length
    ? `Great. Let's practice these words together: ${targetWords.join(", ")}. ${userText}`
    : `Great. Let's continue the conversation. ${userText}`;

  const corrections = targetWords.map((word) => ({
    original: word,
    corrected: word,
    type: "vocabulary",
    explanation: "대화에서 해당 단어를 한 번 더 문장으로 사용해 보세요.",
  }));

  const claudeResult = await generateClaudeChat({
    messages,
    targetWords,
    level,
    scenario,
  });

  const responseText = claudeResult.ok ? claudeResult.content : fallbackText;
  const provider = claudeResult.ok ? "claude" : "mock";
  const warning = claudeResult.ok ? null : claudeResult.error;

  await repository.addChatLog(userId, { messages, responseText, corrections, provider });

  if (shouldStream(req)) {
    res.setHeader("Content-Type", "text/event-stream; charset=utf-8");
    res.setHeader("Cache-Control", "no-cache, no-transform");
    res.setHeader("Connection", "keep-alive");
    if (typeof res.flushHeaders === "function") {
      res.flushHeaders();
    }

    return streamResponse(res, responseText, {
      provider,
      warning,
      corrections,
    });
  }

  return res.json({
    content: responseText,
    done: true,
    provider,
    warning,
    corrections,
  });
}

async function progress(req, res) {
  const userId = getUserId(req);
  const snapshot = await repository.getProgressSnapshot(userId);
  return res.json(summarizeProgress(snapshot));
}

async function getQuizQuestion(req, res) {
  const userId = getUserId(req);
  const words = await repository.listWords(userId);
  const question = buildQuizQuestion(words);

  if (!question) {
    return res.status(400).json({
      error: "not enough words for quiz",
      message: "add at least 4 words first",
    });
  }

  return res.json({
    wordId: question.wordId,
    prompt: question.prompt,
    choices: question.choices,
  });
}

async function submitQuizAnswer(req, res) {
  const userId = getUserId(req);
  const wordId = String(req.body.wordId || "").trim();
  const selected = String(req.body.selected || "").trim();

  if (!wordId || !selected) {
    return res.status(400).json({ error: "wordId and selected are required" });
  }

  const card = await repository.getWordById(userId, wordId);
  if (!card) {
    return res.status(404).json({ error: "word not found" });
  }

  const result = gradeQuiz({ answer: card.translation }, selected);
  const updated = reviewCard(card, result.grade, new Date());

  await repository.replaceWord(userId, wordId, updated);
  await repository.addReview(userId, {
    wordId,
    grade: result.grade,
    source: "quiz",
  });

  return res.json({
    correct: result.correct,
    grade: result.grade,
    answer: card.translation,
    nextReview: updated.nextReview,
  });
}

module.exports = {
  listWords,
  createWord,
  updateReview,
  speechScore,
  chat,
  progress,
  getQuizQuestion,
  submitQuizAnswer,
};
