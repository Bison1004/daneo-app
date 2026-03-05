function estimateCEFR(totalWords, reviewAccuracy, complexity = 0.5) {
  const words = Number(totalWords || 0);
  const accuracy = Number(reviewAccuracy || 0);
  const cpx = Math.max(0, Math.min(1, Number(complexity || 0.5)));

  if (words >= 4500 && accuracy >= 0.85 && cpx >= 0.75) return "C1";
  if (words >= 3000 && accuracy >= 0.8 && cpx >= 0.65) return "B2";
  if (words >= 1800 && accuracy >= 0.72 && cpx >= 0.55) return "B1";
  if (words >= 900 && accuracy >= 0.6) return "A2";
  return "A1";
}

function summarizeProgress({ words = [], reviews = [], speechLogs = [], chatLogs = [] }) {
  const totalWords = words.length;
  const reviewed = reviews.length;
  const passed = reviews.filter((item) => Number(item.grade) >= 3).length;
  const reviewAccuracy = reviewed === 0 ? 0 : passed / reviewed;

  const speechAverage = speechLogs.length
    ? speechLogs.reduce((sum, item) => sum + Number(item.overall || 0), 0) / speechLogs.length
    : 0;

  const streak = Math.min(30, Math.max(1, Math.ceil((reviewed + chatLogs.length) / 3)));
  const estimatedLevel = estimateCEFR(totalWords, reviewAccuracy, speechAverage / 100);

  return {
    streak,
    totalWords,
    todayReviewed: reviewed,
    weeklyAccuracy: Number((reviewAccuracy * 100).toFixed(1)),
    pronunciationAverage: Number(speechAverage.toFixed(1)),
    estimatedLevel,
  };
}

module.exports = {
  estimateCEFR,
  summarizeProgress,
};
