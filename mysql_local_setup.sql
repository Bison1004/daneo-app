-- Local MySQL setup for daneo-app
-- 1) Run this file as a privileged MySQL account (e.g., root)
-- 2) Then set .env DB_USER/DB_PASSWORD/DB_NAME to the same values

CREATE DATABASE IF NOT EXISTS efl_vocab_app
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'admin'@'localhost'
  IDENTIFIED BY 'admin1234!';

GRANT ALL PRIVILEGES ON efl_vocab_app.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;

-- Optional check
-- SHOW DATABASES LIKE 'efl_vocab_app';
-- SELECT user, host FROM mysql.user WHERE user='admin';
