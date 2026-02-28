const studentsRepository = require("../repositories/studentsRepository");

function trimValue(value) {
  return String(value || "").trim();
}

function normalizeStudentInput(body = {}) {
  return {
    student_name: trimValue(body.student_name),
    student_key: trimValue(body.student_key),
    grade: trimValue(body.grade),
    class_name: trimValue(body.class_name),
    status: trimValue(body.status || "active") || "active",
    memo: trimValue(body.memo),
  };
}

function validateStudentInput(student) {
  if (!student.student_name) {
    return "학생 이름은 필수입니다.";
  }
  if (!student.student_key) {
    return "학생 키는 필수입니다.";
  }
  if (!["active", "inactive"].includes(student.status)) {
    return "상태는 active 또는 inactive만 가능합니다.";
  }
  return null;
}

async function createStudent(req, res) {
  try {
    const student = normalizeStudentInput(req.body);
    const validationError = validateStudentInput(student);
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    const duplicated = await studentsRepository.getStudentByKey(student.student_key);
    if (duplicated) {
      return res.status(409).json({ error: "이미 사용 중인 학생 키입니다. 다른 키를 사용해주세요." });
    }

    const studentId = await studentsRepository.createStudent(student);
    const created = await studentsRepository.getStudentById(studentId);

    return res.status(201).json({
      message: "학생이 등록되었습니다.",
      student: created,
    });
  } catch (error) {
    return res.status(500).json({ error: `학생 등록 중 오류가 발생했습니다: ${error.message}` });
  }
}

async function listStudents(req, res) {
  try {
    const filters = {
      student_name: trimValue(req.query.student_name),
      student_key: trimValue(req.query.student_key),
      grade: trimValue(req.query.grade),
      class_name: trimValue(req.query.class_name),
      status: trimValue(req.query.status),
    };

    const students = await studentsRepository.listStudents(filters);
    return res.json({ count: students.length, students });
  } catch (error) {
    return res.status(500).json({ error: `학생 목록 조회 중 오류가 발생했습니다: ${error.message}` });
  }
}

async function getStudent(req, res) {
  try {
    const studentId = Number(req.params.id);
    if (!Number.isInteger(studentId) || studentId <= 0) {
      return res.status(400).json({ error: "유효한 학생 번호를 입력해주세요." });
    }

    const student = await studentsRepository.getStudentById(studentId);
    if (!student) {
      return res.status(404).json({ error: "학생 정보를 찾을 수 없습니다." });
    }

    return res.json({ student });
  } catch (error) {
    return res.status(500).json({ error: `학생 조회 중 오류가 발생했습니다: ${error.message}` });
  }
}

async function updateStudent(req, res) {
  try {
    const studentId = Number(req.params.id);
    if (!Number.isInteger(studentId) || studentId <= 0) {
      return res.status(400).json({ error: "유효한 학생 번호를 입력해주세요." });
    }

    const existing = await studentsRepository.getStudentById(studentId);
    if (!existing) {
      return res.status(404).json({ error: "수정할 학생이 존재하지 않습니다." });
    }

    const student = normalizeStudentInput(req.body);
    const validationError = validateStudentInput(student);
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    const duplicated = await studentsRepository.getStudentByKeyExcludeId(student.student_key, studentId);
    if (duplicated) {
      return res.status(409).json({ error: "이미 사용 중인 학생 키입니다. 다른 키를 사용해주세요." });
    }

    await studentsRepository.updateStudent(studentId, student);
    const updated = await studentsRepository.getStudentById(studentId);

    return res.json({ message: "학생 정보가 수정되었습니다.", student: updated });
  } catch (error) {
    return res.status(500).json({ error: `학생 수정 중 오류가 발생했습니다: ${error.message}` });
  }
}

async function updateStudentStatus(req, res) {
  try {
    const studentId = Number(req.params.id);
    const status = trimValue(req.body.status);

    if (!Number.isInteger(studentId) || studentId <= 0) {
      return res.status(400).json({ error: "유효한 학생 번호를 입력해주세요." });
    }
    if (!["active", "inactive"].includes(status)) {
      return res.status(400).json({ error: "상태는 active 또는 inactive만 가능합니다." });
    }

    const existing = await studentsRepository.getStudentById(studentId);
    if (!existing) {
      return res.status(404).json({ error: "상태를 변경할 학생이 존재하지 않습니다." });
    }

    await studentsRepository.updateStudentStatus(studentId, status);
    const updated = await studentsRepository.getStudentById(studentId);

    return res.json({ message: "학생 상태가 변경되었습니다.", student: updated });
  } catch (error) {
    return res.status(500).json({ error: `상태 변경 중 오류가 발생했습니다: ${error.message}` });
  }
}

module.exports = {
  createStudent,
  listStudents,
  getStudent,
  updateStudent,
  updateStudentStatus,
};
