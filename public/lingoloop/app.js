const statusEl = document.getElementById("status");
const authStatusEl = document.getElementById("authStatus");
const tabs = [...document.querySelectorAll(".tab")];
const sections = [...document.querySelectorAll("[data-content]")];
const wordListEl = document.getElementById("wordList");
const installBtn = document.getElementById("installBtn");
const accessKeyInput = document.getElementById("accessKeyInput");
const saveAccessKeyBtn = document.getElementById("saveAccessKeyBtn");
const displayNameInput = document.getElementById("displayNameInput");
const guestLoginBtn = document.getElementById("guestLoginBtn");

const loadQuizBtn = document.getElementById("loadQuizBtn");
const quizBox = document.getElementById("quizBox");
const quizPrompt = document.getElementById("quizPrompt");
const quizChoices = document.getElementById("quizChoices");
const quizResult = document.getElementById("quizResult");

let installPrompt = null;
let currentQuiz = null;

function setStatus(text, isError = false) {
  statusEl.textContent = text;
  statusEl.style.color = isError ? "#ff8d8d" : "#4cd4a0";
}

function setAuthStatus(text, isError = false) {
  authStatusEl.textContent = text;
  authStatusEl.style.color = isError ? "#ff8d8d" : "#4cd4a0";
}

function getStoredToken() {
  return localStorage.getItem("lingoloop_token") || "";
}

function getStoredUser() {
  const raw = localStorage.getItem("lingoloop_user");
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch (_) {
    return null;
  }
}

async function fetchJSON(url, options = {}) {
  const accessKey = localStorage.getItem("lingoloop_access_key") || "";
  const token = getStoredToken();

  const mergedHeaders = {
    ...(options.headers || {}),
  };
  if (accessKey.trim()) mergedHeaders["x-lingoloop-key"] = accessKey.trim();
  if (token.trim()) mergedHeaders.authorization = `Bearer ${token.trim()}`;

  const response = await fetch(url, {
    ...options,
    headers: mergedHeaders,
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || data.error || `HTTP ${response.status}`);
  }
  return data;
}

function switchTab(tabName) {
  tabs.forEach((tab) => tab.classList.toggle("active", tab.dataset.tab === tabName));
  sections.forEach((section) => section.classList.toggle("hidden", section.dataset.content !== tabName));
}

tabs.forEach((tab) => {
  tab.addEventListener("click", () => switchTab(tab.dataset.tab));
});

async function guestLogin() {
  try {
    const name = displayNameInput.value.trim() || "Learner";
    const result = await fetchJSON("/api/auth/guest", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name }),
    });

    localStorage.setItem("lingoloop_token", result.token);
    localStorage.setItem("lingoloop_user", JSON.stringify(result.user));
    setAuthStatus(`로그인됨: ${result.user.name} (${result.user.userId})`);
    return true;
  } catch (error) {
    setAuthStatus(error.message, true);
    return false;
  }
}

async function ensureAuthenticated() {
  if (getStoredToken()) return true;
  return guestLogin();
}

async function loadWords() {
  try {
    if (!(await ensureAuthenticated())) return;

    const type = document.getElementById("wordType").value;
    const data = await fetchJSON(`/api/words?type=${encodeURIComponent(type)}&limit=20`);
    wordListEl.innerHTML = data.cards
      .map((card) => `<li><b>${card.word}</b> - ${card.translation}<br/><small>next: ${new Date(card.nextReview).toLocaleString()}</small></li>`)
      .join("");
    setStatus(`단어 ${data.cards.length}개 로드 완료`);
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function addWord(event) {
  event.preventDefault();
  try {
    if (!(await ensureAuthenticated())) return;

    const word = document.getElementById("wordInput").value.trim();
    const translation = document.getElementById("translationInput").value.trim();
    if (!word || !translation) return;

    await fetchJSON("/api/words", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ word, translation }),
    });

    event.target.reset();
    await loadWords();
    setStatus("단어를 추가했습니다.");
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function loadQuizQuestion() {
  try {
    if (!(await ensureAuthenticated())) return;

    const question = await fetchJSON("/api/quiz/question");
    currentQuiz = question;

    quizPrompt.textContent = `Q. ${question.prompt} 의 뜻은?`;
    quizChoices.innerHTML = question.choices
      .map((choice) => `<button type="button" class="quiz-choice" data-choice="${choice.replace(/"/g, "&quot;")}">${choice}</button>`)
      .join("");
    quizBox.classList.remove("hidden");
    quizResult.textContent = "";

    [...quizChoices.querySelectorAll(".quiz-choice")].forEach((button) => {
      button.addEventListener("click", () => submitQuizAnswer(button.dataset.choice));
    });
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function submitQuizAnswer(selected) {
  try {
    if (!currentQuiz) return;

    const result = await fetchJSON("/api/quiz/submit", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        wordId: currentQuiz.wordId,
        selected,
      }),
    });

    quizResult.textContent = JSON.stringify(result, null, 2);
    setStatus(result.correct ? "정답입니다." : "오답입니다. SRS에 반영했습니다.");
    await loadWords();
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function scoreSpeech() {
  try {
    if (!(await ensureAuthenticated())) return;

    const targetText = document.getElementById("targetText").value;
    const spokenText = document.getElementById("spokenText").value;
    const result = await fetchJSON("/api/speech/score", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ targetText, spokenText, confidence: 0.75 }),
    });
    document.getElementById("speechResult").textContent = JSON.stringify(result, null, 2);
    setStatus("발음 점수를 계산했습니다.");
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function sendChat() {
  try {
    if (!(await ensureAuthenticated())) return;

    const content = document.getElementById("chatInput").value.trim();
    const result = await fetchJSON("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content }],
        targetWords: ["review", "practice"],
      }),
    });
    document.getElementById("chatResult").textContent = JSON.stringify(result, null, 2);
    setStatus("대화 응답을 받았습니다.");
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function loadProgress() {
  try {
    if (!(await ensureAuthenticated())) return;

    const result = await fetchJSON("/api/progress");
    document.getElementById("progressResult").textContent = JSON.stringify(result, null, 2);
    setStatus("진도 정보를 갱신했습니다.");
  } catch (error) {
    setStatus(error.message, true);
  }
}

document.getElementById("loadWordsBtn").addEventListener("click", loadWords);
document.getElementById("addWordForm").addEventListener("submit", addWord);
document.getElementById("scoreSpeechBtn").addEventListener("click", scoreSpeech);
document.getElementById("sendChatBtn").addEventListener("click", sendChat);
document.getElementById("loadProgressBtn").addEventListener("click", loadProgress);
loadQuizBtn.addEventListener("click", loadQuizQuestion);

saveAccessKeyBtn.addEventListener("click", () => {
  localStorage.setItem("lingoloop_access_key", accessKeyInput.value.trim());
  setStatus("접근키를 저장했습니다.");
});

guestLoginBtn.addEventListener("click", guestLogin);

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault();
  installPrompt = event;
  installBtn.hidden = false;
});

installBtn.addEventListener("click", async () => {
  if (!installPrompt) return;
  installPrompt.prompt();
  await installPrompt.userChoice;
  installPrompt = null;
  installBtn.hidden = true;
});

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/lingoloop/sw.js").catch(() => {});
}

accessKeyInput.value = localStorage.getItem("lingoloop_access_key") || "";
const user = getStoredUser();
if (user) {
  displayNameInput.value = user.name || "";
  setAuthStatus(`로그인됨: ${user.name} (${user.userId})`);
}

loadWords();
