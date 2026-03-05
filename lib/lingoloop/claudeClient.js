function extractTextFromAnthropicContent(content) {
  if (!Array.isArray(content)) return "";
  return content
    .filter((block) => block && block.type === "text")
    .map((block) => block.text || "")
    .join("\n")
    .trim();
}

function buildSystemPrompt({ level, targetWords }) {
  const words = Array.isArray(targetWords) ? targetWords.filter(Boolean).join(", ") : "";
  return [
    "You are a concise English conversation partner for Korean learners.",
    `Learner level: ${level || "A2"}`,
    words ? `Try to naturally include these target words: ${words}.` : "No required target words.",
    "After your reply, provide short correction notes in Korean.",
  ].join(" ");
}

async function generateClaudeChat({ messages, targetWords, level, scenario }) {
  const apiKey = String(process.env.ANTHROPIC_API_KEY || "").trim();
  if (!apiKey) {
    return { ok: false, error: "ANTHROPIC_API_KEY is not configured" };
  }

  const model = String(process.env.CLAUDE_MODEL || "claude-sonnet-4-5").trim();
  const maxTokens = Number(process.env.MAX_TOKENS_PER_CHAT || 800);

  const payload = {
    model,
    max_tokens: Number.isFinite(maxTokens) && maxTokens > 0 ? maxTokens : 800,
    system: buildSystemPrompt({ level, targetWords }),
    messages: [
      ...(scenario ? [{ role: "user", content: `Scenario: ${scenario}` }] : []),
      ...(Array.isArray(messages) ? messages : []),
    ],
    temperature: 0.6,
  };

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify(payload),
  });

  const data = await response.json();
  if (!response.ok) {
    return {
      ok: false,
      error: data?.error?.message || `Claude API failed (${response.status})`,
    };
  }

  return {
    ok: true,
    content: extractTextFromAnthropicContent(data.content),
    raw: data,
  };
}

module.exports = {
  generateClaudeChat,
};
