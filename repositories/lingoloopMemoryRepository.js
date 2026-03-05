const state = {
  words: [],
  reviews: [],
  speechLogs: [],
  chatLogs: [],
};

function createWord(input) {
  const now = new Date();
  const id = String(state.words.length + 1);

  const word = {
    id,
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

function getWordById(id) {
  return state.words.find((item) => item.id === String(id));
}

function replaceWord(id, updatedWord) {
  const idx = state.words.findIndex((item) => item.id === String(id));
  if (idx === -1) return null;
  state.words[idx] = updatedWord;
  return state.words[idx];
}

function addReview(log) {
  state.reviews.push({ ...log, createdAt: new Date() });
}

function addSpeechLog(log) {
  state.speechLogs.push({ ...log, createdAt: new Date() });
}

function addChatLog(log) {
  state.chatLogs.push({ ...log, createdAt: new Date() });
}

function listWords() {
  return state.words.slice();
}

function getProgressSnapshot() {
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
