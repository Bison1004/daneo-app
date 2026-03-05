function normalizeText(input) {
  return String(input || "")
    .toLowerCase()
    .replace(/[^a-z0-9\s']/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function scorePronunciation(spokenText, targetText, confidence = 0.5) {
  const spokenTokens = normalizeText(spokenText).split(" ").filter(Boolean);
  const targetTokens = normalizeText(targetText).split(" ").filter(Boolean);
  const spokenSet = new Set(spokenTokens);

  const matchedWords = targetTokens.filter((token) => spokenSet.has(token));
  const missedWords = targetTokens.filter((token) => !spokenSet.has(token));

  const lexicalScore = targetTokens.length === 0 ? 0 : matchedWords.length / targetTokens.length;
  const confidenceScore = Math.max(0, Math.min(1, Number(confidence)));
  const overall = Math.round((lexicalScore * 0.8 + confidenceScore * 0.2) * 100);

  let feedback = "잘 하고 있어요. 문장을 한 번 더 또박또박 말해보세요.";
  if (overall < 50) {
    feedback = "핵심 단어 누락이 많습니다. 단어를 천천히 끊어서 다시 읽어보세요.";
  } else if (overall < 75) {
    feedback = "좋아요. 강세와 끝소리를 더 분명히 내면 점수가 올라갑니다.";
  }

  return {
    overall,
    matchedWords,
    missedWords,
    feedback,
  };
}

module.exports = {
  scorePronunciation,
};
