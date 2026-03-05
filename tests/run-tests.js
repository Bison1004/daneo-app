const assert = require("node:assert/strict");

function run(name, fn) {
  try {
    fn();
    console.log(`[PASS] ${name}`);
  } catch (error) {
    console.error(`[FAIL] ${name}`);
    console.error(error);
    process.exitCode = 1;
  }
}

run("srs: reset on low grade", () => {
  const { reviewCard } = require("../lib/lingoloop/srsEngine");
  const card = { easeFactor: 2.5, interval: 6, repetitions: 2, nextReview: new Date("2026-03-01") };
  const updated = reviewCard(card, 1, new Date("2026-03-05"));
  assert.equal(updated.repetitions, 0);
  assert.equal(updated.interval, 1);
});

run("srs: grow on good grade", () => {
  const { reviewCard } = require("../lib/lingoloop/srsEngine");
  const card = { easeFactor: 2.5, interval: 6, repetitions: 2, nextReview: new Date("2026-03-01") };
  const updated = reviewCard(card, 4, new Date("2026-03-05"));
  assert.equal(updated.repetitions, 3);
  assert.ok(updated.interval >= 10);
});

run("token: issue and verify", () => {
  process.env.LINGOLOOP_JWT_SECRET = "test-secret";
  const { issueToken, verifyToken } = require("../lib/lingoloop/tokenService");
  const token = issueToken({ userId: "u1", name: "Tester" });
  const verified = verifyToken(token);
  assert.equal(verified.ok, true);
  assert.equal(verified.payload.sub, "u1");
});

run("quiz: build question", () => {
  const { buildQuizQuestion } = require("../lib/lingoloop/quizEngine");
  const cards = [
    { id: "1", word: "apple", translation: "사과" },
    { id: "2", word: "book", translation: "책" },
    { id: "3", word: "cat", translation: "고양이" },
    { id: "4", word: "dog", translation: "개" },
  ];
  const q = buildQuizQuestion(cards);
  assert.ok(q);
  assert.equal(q.choices.length, 4);
});

if (!process.exitCode) {
  console.log("All tests passed.");
}
