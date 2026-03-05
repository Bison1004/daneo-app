const crypto = require("crypto");

function base64urlEncode(input) {
  return Buffer.from(input)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function base64urlDecode(input) {
  const padded = input.replace(/-/g, "+").replace(/_/g, "/") + "===".slice((input.length + 3) % 4);
  return Buffer.from(padded, "base64").toString("utf8");
}

function sign(content, secret) {
  return crypto
    .createHmac("sha256", secret)
    .update(content)
    .digest("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function getTokenSecret() {
  return String(process.env.LINGOLOOP_JWT_SECRET || "").trim() || "lingoloop-dev-secret";
}

function getExpirySeconds() {
  const value = Number(process.env.LINGOLOOP_JWT_EXPIRES_SEC || 7 * 24 * 60 * 60);
  return Number.isFinite(value) && value > 0 ? Math.floor(value) : 7 * 24 * 60 * 60;
}

function issueToken(user) {
  const header = { alg: "HS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    sub: String(user.userId),
    name: String(user.name || "Learner"),
    role: "learner",
    iat: now,
    exp: now + getExpirySeconds(),
  };

  const encodedHeader = base64urlEncode(JSON.stringify(header));
  const encodedPayload = base64urlEncode(JSON.stringify(payload));
  const unsigned = `${encodedHeader}.${encodedPayload}`;
  const signature = sign(unsigned, getTokenSecret());

  return `${unsigned}.${signature}`;
}

function verifyToken(token) {
  if (!token || typeof token !== "string") return { ok: false, error: "missing token" };
  const parts = token.split(".");
  if (parts.length !== 3) return { ok: false, error: "malformed token" };

  const [encodedHeader, encodedPayload, signature] = parts;
  const unsigned = `${encodedHeader}.${encodedPayload}`;
  const expected = sign(unsigned, getTokenSecret());
  if (signature !== expected) return { ok: false, error: "invalid signature" };

  let payload;
  try {
    payload = JSON.parse(base64urlDecode(encodedPayload));
  } catch (_) {
    return { ok: false, error: "invalid payload" };
  }

  const now = Math.floor(Date.now() / 1000);
  if (!payload.exp || payload.exp < now) return { ok: false, error: "token expired" };

  return { ok: true, payload };
}

module.exports = {
  issueToken,
  verifyToken,
};
