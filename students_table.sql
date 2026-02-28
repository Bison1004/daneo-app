SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL,
  student_key VARCHAR(64) NOT NULL,
  grade VARCHAR(20) NULL,
  class_name VARCHAR(20) NULL,
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  memo TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_students_student_key (student_key),
  INDEX idx_students_name (student_name),
  INDEX idx_students_grade_class (grade, class_name),
  INDEX idx_students_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
