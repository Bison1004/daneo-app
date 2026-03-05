function parsePositiveInt(value, fallback) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) return fallback;
  return Math.floor(parsed);
}

function createFixedWindowLimiter({ windowMs, maxRequests, keyPrefix }) {
  const bucket = new Map();

  return function fixedWindowRateLimit(req, res, next) {
    const now = Date.now();
    const ip = req.ip || req.connection.remoteAddress || "unknown";
    const key = `${keyPrefix}:${ip}`;
    const current = bucket.get(key);

    if (!current || current.resetAt <= now) {
      bucket.set(key, { count: 1, resetAt: now + windowMs });
      return next();
    }

    if (current.count >= maxRequests) {
      const retryAfter = Math.max(1, Math.ceil((current.resetAt - now) / 1000));
      res.setHeader("Retry-After", String(retryAfter));
      return res.status(429).json({
        error: "rate limit exceeded",
        retryAfter,
      });
    }

    current.count += 1;
    bucket.set(key, current);
    return next();
  };
}

const generalWindowMs = parsePositiveInt(process.env.LINGOLOOP_RATE_WINDOW_MS, 60_000);
const generalMaxRequests = parsePositiveInt(process.env.LINGOLOOP_RATE_MAX, 60);
const chatWindowMs = parsePositiveInt(process.env.LINGOLOOP_CHAT_WINDOW_MS, 86_400_000);
const chatMaxRequests = parsePositiveInt(process.env.DAILY_CHAT_LIMIT, 20);

const lingoloopGeneralRateLimit = createFixedWindowLimiter({
  windowMs: generalWindowMs,
  maxRequests: generalMaxRequests,
  keyPrefix: "lingoloop:general",
});

const lingoloopChatDailyLimit = createFixedWindowLimiter({
  windowMs: chatWindowMs,
  maxRequests: chatMaxRequests,
  keyPrefix: "lingoloop:chat",
});

module.exports = {
  lingoloopGeneralRateLimit,
  lingoloopChatDailyLimit,
};
