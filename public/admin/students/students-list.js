const tableBody = document.getElementById("studentsTableBody");
const messageEl = document.getElementById("message");

const filterName = document.getElementById("filterName");
const filterKey = document.getElementById("filterKey");
const filterGrade = document.getElementById("filterGrade");
const filterClass = document.getElementById("filterClass");
const filterStatus = document.getElementById("filterStatus");

const searchBtn = document.getElementById("searchBtn");
const resetBtn = document.getElementById("resetBtn");

function showMessage(text, type = "muted") {
  messageEl.textContent = text;
  messageEl.className = `message ${type}`;
}

function escapeHtml(text) {
  return String(text || "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function formatDate(dateValue) {
  if (!dateValue) return "-";
  const d = new Date(dateValue);
  if (Number.isNaN(d.getTime())) return String(dateValue);
  return d.toLocaleString("ko-KR", { hour12: false });
}

function buildQuery() {
  const params = new URLSearchParams();

  const student_name = filterName.value.trim();
  const student_key = filterKey.value.trim();
  const grade = filterGrade.value.trim();
  const class_name = filterClass.value.trim();
  const status = filterStatus.value.trim();

  if (student_name) params.set("student_name", student_name);
  if (student_key) params.set("student_key", student_key);
  if (grade) params.set("grade", grade);
  if (class_name) params.set("class_name", class_name);
  if (status) params.set("status", status);

  return params.toString();
}

function renderTable(students) {
  if (!students.length) {
    tableBody.innerHTML = `
      <tr>
        <td colspan="9" class="muted">조회 결과가 없습니다.</td>
      </tr>
    `;
    return;
  }

  tableBody.innerHTML = students.map((student) => {
    const statusClass = student.status === "active" ? "active" : "inactive";
    const nextStatus = student.status === "active" ? "inactive" : "active";
    const disableLabel = student.status === "active" ? "비활성화" : "활성화";

    return `
      <tr>
        <td>${student.student_id}</td>
        <td>${escapeHtml(student.student_name)}</td>
        <td>${escapeHtml(student.student_key)}</td>
        <td>${escapeHtml(student.grade || "-")}</td>
        <td>${escapeHtml(student.class_name || "-")}</td>
        <td><span class="${statusClass}">${escapeHtml(student.status)}</span></td>
        <td>${escapeHtml(formatDate(student.created_at))}</td>
        <td>
          <a href="/admin/students/new?id=${student.student_id}">
            <button type="button">수정</button>
          </a>
        </td>
        <td>
          <button type="button" data-id="${student.student_id}" data-status="${nextStatus}">${disableLabel}</button>
        </td>
      </tr>
    `;
  }).join("");
}

async function loadStudents() {
  try {
    showMessage("학생 목록을 불러오는 중입니다...", "muted");
    const queryString = buildQuery();
    const url = queryString ? `/api/admin/students?${queryString}` : "/api/admin/students";

    const response = await fetch(url);
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "학생 목록 조회에 실패했습니다.");
    }

    renderTable(data.students || []);
    showMessage(`총 ${data.count || 0}명의 학생이 조회되었습니다.`, "success");
  } catch (error) {
    renderTable([]);
    showMessage(error.message, "error");
  }
}

async function updateStatus(studentId, status) {
  const confirmMessage = status === "inactive"
    ? "이 학생을 비활성화하시겠습니까?"
    : "이 학생을 다시 활성화하시겠습니까?";

  if (!window.confirm(confirmMessage)) return;

  try {
    showMessage("상태를 변경하는 중입니다...", "muted");

    const response = await fetch(`/api/admin/students/${studentId}/status`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status }),
    });

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.error || "상태 변경에 실패했습니다.");
    }

    showMessage(data.message || "학생 상태가 변경되었습니다.", "success");
    await loadStudents();
  } catch (error) {
    showMessage(error.message, "error");
  }
}

searchBtn.addEventListener("click", loadStudents);

resetBtn.addEventListener("click", () => {
  filterName.value = "";
  filterKey.value = "";
  filterGrade.value = "";
  filterClass.value = "";
  filterStatus.value = "";
  loadStudents();
});

tableBody.addEventListener("click", async (event) => {
  const target = event.target;
  if (!(target instanceof HTMLButtonElement)) return;

  const studentId = target.dataset.id;
  const status = target.dataset.status;

  if (!studentId || !status) return;
  await updateStatus(studentId, status);
});

window.addEventListener("load", loadStudents);
