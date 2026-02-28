function parseBasicAuthHeader(authHeader) {
  if (!authHeader || !authHeader.startsWith("Basic ")) return null;

  const encoded = authHeader.slice(6);
  const decoded = Buffer.from(encoded, "base64").toString("utf8");
  const separatorIndex = decoded.indexOf(":");
  if (separatorIndex < 0) return null;

  return {
    username: decoded.slice(0, separatorIndex),
    password: decoded.slice(separatorIndex + 1),
  };
}

function requireAdminAuth(req, res, next) {
  const expectedUsername = process.env.ADMIN_USERNAME || "admin";
  const expectedPassword = process.env.ADMIN_PASSWORD || "admin1234";

  const credentials = parseBasicAuthHeader(req.headers.authorization);

  if (!credentials) {
    res.setHeader("WWW-Authenticate", 'Basic realm="Admin Area"');
    return res.status(401).json({
      error: "관리자 인증이 필요합니다. 브라우저 인증창에 관리자 계정을 입력하세요.",
    });
  }

  if (credentials.username !== expectedUsername || credentials.password !== expectedPassword) {
    return res.status(403).json({ error: "관리자 권한이 없습니다." });
  }

  next();
}

module.exports = { requireAdminAuth };
