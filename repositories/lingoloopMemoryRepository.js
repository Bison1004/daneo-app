const stateByUser = new Map();

function getState(userId) {
  const key = String(userId || "public");
  if (!stateByUser.has(key)) {
    stateByUser.set(key, {
      words: [],
      reviews: [],
      speechLogs: [],
      chatLogs: [],
    });
  }
  return stateByUser.get(key);
}

async function createWord(userId, input) {
  const state = getState(userId);
  const now = new Date();
  const id = String(state.words.length + 1);

  const word = {
    id,
    userId: String(userId),
    word: String(input.word || "").trim(),
    translation: String(input.translation || "").trim(),
    examples: Array.isArray(input.examples) ? input.examples.slice(0, 3) : [],
    tags: Array.isArray(input.tags) ? input.tags : [],
    easeFactor: 2.5,
    interval: 0,
    repetitions: 0,
    nextReview: now,
    createdAt: now,
  };

  state.words.push(word);
  return word;
}

async function getWordById(userId, id) {
  const state = getState(userId);
  return state.words.find((item) => item.id === String(id)) || null;
}

async function replaceWord(userId, id, updatedWord) {
  const state = getState(userId);
  const idx = state.words.findIndex((item) => item.id === String(id));
  if (idx === -1) return null;
  state.words[idx] = updatedWord;
  return state.words[idx];
}

async function addReview(userId, log) {
  const state = getState(userId);
  state.reviews.push({ ...log, createdAt: new Date() });
}

async function addSpeechLog(userId, log) {
  const state = getState(userId);
  state.speechLogs.push({ ...log, createdAt: new Date() });
}

async function addChatLog(userId, log) {
  const state = getState(userId);
  state.chatLogs.push({ ...log, createdAt: new Date() });
}

async function listWords(userId) {
  const state = getState(userId);
  return state.words.slice();
}

async function getProgressSnapshot(userId) {
  const state = getState(userId);
  return {
    words: state.words.slice(),
    reviews: state.reviews.slice(),
    speechLogs: state.speechLogs.slice(),
    chatLogs: state.chatLogs.slice(),
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
};
