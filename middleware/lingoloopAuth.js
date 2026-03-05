const { verifyToken } = require("../lib/lingoloop/tokenService");

function enforceLingoloopAccess(req, res, next) {
  const expectedKey = String(process.env.LINGOLOOP_ACCESS_KEY || "").trim();
  if (!expectedKey) {
    return next();
  }

  const providedKey = String(req.header("x-lingoloop-key") || "").trim();
  if (!providedKey || providedKey !== expectedKey) {
    return res.status(401).json({
      error: "unauthorized",
      message: "invalid lingoloop access key",
    });
  }

  return next();
}

function attachLingoloopUser(req, _res, next) {
  const auth = String(req.header("authorization") || "");
  if (!auth.toLowerCase().startsWith("bearer ")) {
    req.lingoloopUser = null;
    return next();
  }

  const token = auth.slice(7).trim();
  const result = verifyToken(token);
  if (!result.ok) {
    req.lingoloopUser = null;
    req.lingoloopAuthError = result.error;
    return next();
  }

  req.lingoloopUser = {
    userId: String(result.payload.sub),
    name: String(result.payload.name || "Learner"),
    role: String(result.payload.role || "learner"),
  };

  return next();
}

function requireLingoloopUser(req, res, next) {
  const requireAuth = String(process.env.LINGOLOOP_REQUIRE_AUTH || "1").trim() !== "0";
  if (!requireAuth) {
    if (!req.lingoloopUser) {
      req.lingoloopUser = { userId: "public", name: "Public", role: "learner" };
    }
    return next();
  }

  if (!req.lingoloopUser) {
    return res.status(401).json({
      error: "unauthorized",
      message: req.lingoloopAuthError || "missing or invalid bearer token",
    });
  }

  return next();
}

module.exports = {
  enforceLingoloopAccess,
  attachLingoloopUser,
  requireLingoloopUser,
};
