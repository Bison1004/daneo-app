function shuffle(items) {
  const copied = items.slice();
  for (let i = copied.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copied[i], copied[j]] = [copied[j], copied[i]];
  }
  return copied;
}

function buildQuizQuestion(cards) {
  if (!Array.isArray(cards) || cards.length < 4) {
    return null;
  }

  const target = cards[Math.floor(Math.random() * cards.length)];
  const distractors = shuffle(
    cards.filter((card) => card.id !== target.id).map((card) => card.translation)
  ).slice(0, 3);

  const choices = shuffle([target.translation, ...distractors]);

  return {
    wordId: String(target.id),
    prompt: target.word,
    choices,
    answer: target.translation,
  };
}

function gradeQuiz(question, selected) {
  const correct = String(selected || "") === String(question.answer || "");
  const grade = correct ? 4 : 1;
  return { correct, grade };
}

module.exports = {
  buildQuizQuestion,
  gradeQuiz,
};
