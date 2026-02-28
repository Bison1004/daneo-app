const params = new URLSearchParams(window.location.search);
const studentId = params.get("id");
const isEditMode = Boolean(studentId);

const pageMode = document.getElementById("pageMode");
const form = document.getElementById("studentForm");
const messageEl = document.getElementById("message");
const submitBtn = document.getElementById("submitBtn");

const studentNameEl = document.getElementById("studentName");
const studentKeyEl = document.getElementById("studentKey");
const gradeEl = document.getElementById("grade");
const classNameEl = document.getElementById("className");
const statusEl = document.getElementById("status");
const memoEl = document.getElementById("memo");
const generateKeyBtn = document.getElementById("generateKeyBtn");

function showMessage(text, type = "muted") {
  messageEl.textContent = text;
  messageEl.className = `message ${type}`;
}

function generateStudentKey() {
  const random = Math.random().toString(36).slice(2, 8).toUpperCase();
  const timestampTail = String(Date.now()).slice(-4);
  return `STD-${random}${timestampTail}`;
}

function getPayload() {
  return {
    student_name: studentNameEl.value.trim(),
    student_key: studentKeyEl.value.trim(),
    grade: gradeEl.value.trim(),
    class_name: classNameEl.value.trim(),
    status: statusEl.value,
    memo: memoEl.value.trim(),
  };
}

function fillForm(student) {
  studentNameEl.value = student.student_name || "";
  studentKeyEl.value = student.student_key || "";
  gradeEl.value = student.grade || "";
  classNameEl.value = student.class_name || "";
  statusEl.value = student.status || "active";
  memoEl.value = student.memo || "";
}

async function loadStudentForEdit() {
  if (!isEditMode) return;

  try {
    pageMode.textContent = "학생 수정";
    submitBtn.textContent = "수정 저장";
    showMessage("학생 정보를 불러오는 중입니다...", "muted");

    const response = await fetch(`/api/admin/students/${studentId}`);
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "학생 조회에 실패했습니다.");
    }

    fillForm(data.student);
    showMessage("수정할 정보를 확인한 뒤 저장하세요.", "muted");
  } catch (error) {
    showMessage(error.message, "error");
  }
}

async function submitForm(event) {
  event.preventDefault();

  const payload = getPayload();

  if (!payload.student_name) {
    showMessage("학생 이름은 필수입니다.", "error");
    return;
  }
  if (!payload.student_key) {
    showMessage("학생 키는 필수입니다.", "error");
    return;
  }

  try {
    showMessage(isEditMode ? "학생 정보를 수정하는 중입니다..." : "학생을 등록하는 중입니다...", "muted");

    const response = await fetch(isEditMode ? `/api/admin/students/${studentId}` : "/api/admin/students", {
      method: isEditMode ? "PUT" : "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.error || "요청 처리에 실패했습니다.");
    }

    showMessage(data.message || (isEditMode ? "학생이 수정되었습니다." : "학생이 등록되었습니다."), "success");

    if (!isEditMode) {
      form.reset();
      statusEl.value = "active";
    }
  } catch (error) {
    showMessage(error.message, "error");
  }
}

generateKeyBtn.addEventListener("click", () => {
  studentKeyEl.value = generateStudentKey();
  showMessage("학생 키가 자동 생성되었습니다.", "success");
});

form.addEventListener("submit", submitForm);
window.addEventListener("load", loadStudentForEdit);
