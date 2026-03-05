const crypto = require("crypto");
const { issueToken } = require("../lib/lingoloop/tokenService");

function createGuestSession(req, res) {
  const name = String(req.body.name || "Learner").trim() || "Learner";
  const userId = String(req.body.userId || `guest_${crypto.randomUUID().slice(0, 8)}`).trim();

  const token = issueToken({ userId, name });

  return res.status(201).json({
    token,
    user: {
      userId,
      name,
      role: "learner",
    },
  });
}

module.exports = {
  createGuestSession,
};
