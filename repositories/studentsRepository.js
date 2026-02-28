const pool = require("../db/pool");

async function createStudent(payload) {
  const sql = `
    INSERT INTO students
      (student_name, student_key, grade, class_name, status, memo)
    VALUES (?, ?, ?, ?, ?, ?)
  `;

  const [result] = await pool.query(sql, [
    payload.student_name,
    payload.student_key,
    payload.grade,
    payload.class_name,
    payload.status,
    payload.memo,
  ]);

  return result.insertId;
}

async function listStudents(filters = {}) {
  const where = [];
  const params = [];

  if (filters.student_name) {
    where.push("student_name LIKE ?");
    params.push(`%${filters.student_name}%`);
  }
  if (filters.student_key) {
    where.push("student_key LIKE ?");
    params.push(`%${filters.student_key}%`);
  }
  if (filters.grade) {
    where.push("grade = ?");
    params.push(filters.grade);
  }
  if (filters.class_name) {
    where.push("class_name = ?");
    params.push(filters.class_name);
  }
  if (filters.status) {
    where.push("status = ?");
    params.push(filters.status);
  }

  const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";

  const sql = `
    SELECT
      student_id,
      student_name,
      student_key,
      grade,
      class_name,
      status,
      memo,
      created_at,
      updated_at
    FROM students
    ${whereSql}
    ORDER BY student_id DESC
  `;

  const [rows] = await pool.query(sql, params);
  return rows;
}

async function getStudentById(studentId) {
  const sql = `
    SELECT
      student_id,
      student_name,
      student_key,
      grade,
      class_name,
      status,
      memo,
      created_at,
      updated_at
    FROM students
    WHERE student_id = ?
    LIMIT 1
  `;
  const [rows] = await pool.query(sql, [studentId]);
  return rows[0] || null;
}

async function getStudentByKey(studentKey) {
  const sql = `
    SELECT
      student_id,
      student_name,
      student_key,
      grade,
      class_name,
      status,
      created_at,
      updated_at
    FROM students
    WHERE student_key = ?
    LIMIT 1
  `;
  const [rows] = await pool.query(sql, [studentKey]);
  return rows[0] || null;
}

async function getStudentByKeyExcludeId(studentKey, studentId) {
  const sql = `
    SELECT student_id
    FROM students
    WHERE student_key = ? AND student_id <> ?
    LIMIT 1
  `;
  const [rows] = await pool.query(sql, [studentKey, studentId]);
  return rows[0] || null;
}

async function updateStudent(studentId, payload) {
  const sql = `
    UPDATE students
    SET
      student_name = ?,
      student_key = ?,
      grade = ?,
      class_name = ?,
      status = ?,
      memo = ?,
      updated_at = CURRENT_TIMESTAMP
    WHERE student_id = ?
  `;

  const [result] = await pool.query(sql, [
    payload.student_name,
    payload.student_key,
    payload.grade,
    payload.class_name,
    payload.status,
    payload.memo,
    studentId,
  ]);

  return result.affectedRows;
}

async function updateStudentStatus(studentId, status) {
  const sql = `
    UPDATE students
    SET status = ?, updated_at = CURRENT_TIMESTAMP
    WHERE student_id = ?
  `;
  const [result] = await pool.query(sql, [status, studentId]);
  return result.affectedRows;
}

module.exports = {
  createStudent,
  listStudents,
  getStudentById,
  getStudentByKey,
  getStudentByKeyExcludeId,
  updateStudent,
  updateStudentStatus,
};
