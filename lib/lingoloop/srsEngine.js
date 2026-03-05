function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function toDate(input) {
  return input instanceof Date ? input : new Date(input);
}

function reviewCard(card, grade, reviewedAt = new Date()) {
  const safeGrade = clamp(Number(grade), 0, 5);
  const previousEase = Math.max(1.3, Number(card.easeFactor || 2.5));
  const previousRepetitions = Math.max(0, Number(card.repetitions || 0));

  let repetitions = previousRepetitions;
  let interval = Number(card.interval || 0);
  let easeFactor = previousEase;

  if (safeGrade < 3) {
    repetitions = 0;
    interval = 1;
  } else {
    repetitions += 1;
    if (repetitions === 1) interval = 1;
    else if (repetitions === 2) interval = 6;
    else interval = Math.max(1, Math.round(interval * easeFactor));

    const efDelta = 0.1 - (5 - safeGrade) * (0.08 + (5 - safeGrade) * 0.02);
    easeFactor = Math.max(1.3, previousEase + efDelta);
  }

  const nextReview = new Date(toDate(reviewedAt).getTime());
  nextReview.setDate(nextReview.getDate() + interval);

  return {
    ...card,
    easeFactor: Number(easeFactor.toFixed(2)),
    repetitions,
    interval,
    nextReview,
    lastGrade: safeGrade,
    reviewedAt: toDate(reviewedAt),
  };
}

function getDueCards(cards, now = new Date(), limit = 50) {
  const nowDate = toDate(now);
  return cards
    .filter((card) => toDate(card.nextReview) <= nowDate)
    .slice(0, limit);
}

function getNewCards(cards, limit = 20) {
  return cards.filter((card) => Number(card.repetitions || 0) === 0).slice(0, limit);
}

function calculateStudySession(cards) {
  const due = getDueCards(cards).length;
  const fresh = getNewCards(cards).length;
  const total = due + fresh;
  const minutes = Math.max(5, Math.ceil(total * 0.75));

  return {
    due,
    new: fresh,
    total,
    minutes,
  };
}

module.exports = {
  reviewCard,
  getDueCards,
  getNewCards,
  calculateStudySession,
};
