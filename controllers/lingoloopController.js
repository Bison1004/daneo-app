const repository = require("../repositories/lingoloopMemoryRepository");
const { reviewCard, getDueCards, getNewCards, calculateStudySession } = require("../lib/lingoloop/srsEngine");
const { scorePronunciation } = require("../lib/lingoloop/speechScorer");
const { summarizeProgress } = require("../lib/lingoloop/progressTracker");

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

async function listWords(req, res) {
  const type = normalizeType(req.query.type);
  const limit = Math.max(1, Math.min(100, Number(req.query.limit || 50)));

  const words = repository.listWords();
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
  const word = String(req.body.word || "").trim();
  const translation = String(req.body.translation || "").trim();

  if (!word || !translation) {
    return res.status(400).json({ error: "word and translation are required" });
  }

  const created = repository.createWord({
    word,
    translation,
    tags: Array.isArray(req.body.tags) ? req.body.tags : [],
    examples: buildExamples(word, translation),
  });

  return res.status(201).json(created);
}

async function updateReview(req, res) {
  const id = String(req.params.id || "").trim();
  const grade = Number(req.body.grade);
  const source = String(req.body.source || "quiz").trim();

  const existing = repository.getWordById(id);
  if (!existing) {
    return res.status(404).json({ error: "word not found" });
  }

  if (Number.isNaN(grade) || grade < 0 || grade > 5) {
    return res.status(400).json({ error: "grade must be between 0 and 5" });
  }

  const updated = reviewCard(existing, grade, new Date());
  repository.replaceWord(id, updated);
  repository.addReview({ wordId: id, grade, source });

  return res.json({
    interval: updated.interval,
    easeFactor: updated.easeFactor,
    nextReview: updated.nextReview,
    repetitions: updated.repetitions,
  });
}

async function speechScore(req, res) {
  const spokenText = String(req.body.spokenText || "").trim();
  const targetText = String(req.body.targetText || "").trim();
  const confidence = Number(req.body.confidence ?? 0.5);

  if (!spokenText || !targetText) {
    return res.status(400).json({ error: "spokenText and targetText are required" });
  }

  const scored = scorePronunciation(spokenText, targetText, confidence);
  repository.addSpeechLog(scored);
  return res.json(scored);
}

async function chat(req, res) {
  const messages = Array.isArray(req.body.messages) ? req.body.messages : [];
  const targetWords = Array.isArray(req.body.targetWords) ? req.body.targetWords : [];

  const userText = messages
    .filter((item) => item && item.role === "user")
    .map((item) => String(item.content || "").trim())
    .filter(Boolean)
    .join(" ");

  const responseText = targetWords.length
    ? `Great. Let's practice these words together: ${targetWords.join(", ")}. ${userText}`
    : `Great. Let's continue the conversation. ${userText}`;

  const corrections = targetWords.map((word) => ({
    original: word,
    corrected: word,
    type: "vocabulary",
    explanation: "대화에서 해당 단어를 한 번 더 문장으로 사용해 보세요.",
  }));

  repository.addChatLog({ messages, responseText, corrections });

  return res.json({
    content: responseText,
    done: true,
    corrections,
  });
}

async function progress(req, res) {
  const snapshot = repository.getProgressSnapshot();
  return res.json(summarizeProgress(snapshot));
}

module.exports = {
  listWords,
  createWord,
  updateReview,
  speechScore,
  chat,
  progress,
};
