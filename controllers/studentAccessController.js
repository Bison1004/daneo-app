const studentsRepository = require("../repositories/studentsRepository");

function trimValue(value) {
  return String(value || "").trim();
}

async function verifyStudentKey(req, res) {
  try {
    const studentKey = trimValue(req.body.student_key);

    if (!studentKey) {
      return res.status(400).json({
        valid: false,
        error: "student_key는 필수입니다.",
      });
    }

    const student = await studentsRepository.getStudentByKey(studentKey);

    if (!student) {
      return res.status(404).json({
        valid: false,
        error: "등록되지 않은 학생 키입니다.",
      });
    }

    if (student.status !== "active") {
      return res.status(403).json({
        valid: false,
        error: "비활성화된 학생입니다. 관리자에게 문의하세요.",
      });
    }

    return res.json({
      valid: true,
      message: "학생 키 확인이 완료되었습니다.",
      student,
    });
  } catch (error) {
    return res.status(500).json({
      valid: false,
      error: `학생 키 확인 중 오류가 발생했습니다: ${error.message}`,
    });
  }
}

module.exports = {
  verifyStudentKey,
};
