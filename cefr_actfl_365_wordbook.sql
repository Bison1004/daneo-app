/* =========================================================
   CEFR/ACTFL EFL 365-Day Wordbook Schema
   - Goal: 10 words/day x 365 days
   - Card fields: headword, IPA, derivatives, example
   - Recommended fields: Korean gloss, collocation, CEFR/ACTFL tag
   - Quality system: fixed 6 selection rules + day-level validations
   ========================================================= */

SET NAMES utf8mb4;

/* ---------------------------------------------------------
   1) Curriculum track + day plan
   --------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS wb_tracks (
  track_id        INT AUTO_INCREMENT PRIMARY KEY,
  track_name      VARCHAR(80) NOT NULL,
  target_grade    VARCHAR(40) NOT NULL,
  cefr_band_min   VARCHAR(16) NOT NULL,
  cefr_band_max   VARCHAR(16) NOT NULL,
  actfl_band_min  VARCHAR(24) NOT NULL,
  actfl_band_max  VARCHAR(24) NOT NULL,
  days_total      INT NOT NULL DEFAULT 365,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_wb_track_name (track_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wb_days (
  day_id          INT AUTO_INCREMENT PRIMARY KEY,
  track_id        INT NOT NULL,
  day_no          INT NOT NULL,
  theme           VARCHAR(120) NOT NULL,
  cefr_tag        VARCHAR(16) NOT NULL,
  actfl_tag       VARCHAR(24) NOT NULL,
  notes           VARCHAR(255),
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_wb_track_day (track_id, day_no),
  CONSTRAINT fk_wb_days_track FOREIGN KEY (track_id) REFERENCES wb_tracks(track_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* ---------------------------------------------------------
   2) Lexeme + card details
   --------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS wb_lexemes (
  lexeme_id            INT AUTO_INCREMENT PRIMARY KEY,
  headword             VARCHAR(64) NOT NULL,
  ipa_us               VARCHAR(64),
  ipa_uk               VARCHAR(64),
  pos                  VARCHAR(32) NOT NULL,
  core_meaning_en      VARCHAR(255) NOT NULL,
  core_meaning_ko      VARCHAR(255),
  cefr_tag             VARCHAR(16) NOT NULL,
  actfl_tag            VARCHAR(24) NOT NULL,
  utility_priority     ENUM('high','medium','low') NOT NULL DEFAULT 'medium',
  is_active            TINYINT(1) NOT NULL DEFAULT 1,
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_wb_lexeme (headword, pos)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wb_derivatives (
  derivative_id        INT AUTO_INCREMENT PRIMARY KEY,
  lexeme_id            INT NOT NULL,
  derivative_word      VARCHAR(64) NOT NULL,
  derivative_pos       VARCHAR(32) NOT NULL,
  note                 VARCHAR(255),
  sort_no              INT NOT NULL DEFAULT 1,
  UNIQUE KEY uq_wb_derivative (lexeme_id, derivative_word, derivative_pos),
  CONSTRAINT fk_wb_derivative_lexeme FOREIGN KEY (lexeme_id) REFERENCES wb_lexemes(lexeme_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wb_collocations (
  collocation_id       INT AUTO_INCREMENT PRIMARY KEY,
  lexeme_id            INT NOT NULL,
  collocation          VARCHAR(128) NOT NULL,
  sort_no              INT NOT NULL DEFAULT 1,
  UNIQUE KEY uq_wb_collocation (lexeme_id, collocation),
  CONSTRAINT fk_wb_collocation_lexeme FOREIGN KEY (lexeme_id) REFERENCES wb_lexemes(lexeme_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wb_examples (
  example_id           INT AUTO_INCREMENT PRIMARY KEY,
  lexeme_id            INT NOT NULL,
  sentence             VARCHAR(255) NOT NULL,
  sentence_ko          VARCHAR(255),
  sort_no              INT NOT NULL DEFAULT 1,
  UNIQUE KEY uq_wb_example (lexeme_id, sentence),
  CONSTRAINT fk_wb_example_lexeme FOREIGN KEY (lexeme_id) REFERENCES wb_lexemes(lexeme_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* ---------------------------------------------------------
   3) Day composition (10 words/day)
   --------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS wb_day_items (
  day_item_id          INT AUTO_INCREMENT PRIMARY KEY,
  day_id               INT NOT NULL,
  lexeme_id            INT NOT NULL,
  sort_no              INT NOT NULL,
  is_required          TINYINT(1) NOT NULL DEFAULT 1,
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_wb_day_item (day_id, lexeme_id),
  UNIQUE KEY uq_wb_day_sort (day_id, sort_no),
  CONSTRAINT fk_wb_day_item_day FOREIGN KEY (day_id) REFERENCES wb_days(day_id) ON DELETE CASCADE,
  CONSTRAINT fk_wb_day_item_lexeme FOREIGN KEY (lexeme_id) REFERENCES wb_lexemes(lexeme_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* ---------------------------------------------------------
   4) Fixed 6 selection rules
   --------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS wb_selection_rules (
  rule_code            VARCHAR(32) PRIMARY KEY,
  rule_name            VARCHAR(80) NOT NULL,
  description          VARCHAR(500) NOT NULL,
  is_active            TINYINT(1) NOT NULL DEFAULT 1,
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wb_day_item_rule_checks (
  check_id             INT AUTO_INCREMENT PRIMARY KEY,
  day_item_id          INT NOT NULL,
  rule_code            VARCHAR(32) NOT NULL,
  passed               TINYINT(1) NOT NULL,
  reviewer_note        VARCHAR(255),
  reviewed_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_wb_item_rule (day_item_id, rule_code),
  CONSTRAINT fk_wb_item_rule_day_item FOREIGN KEY (day_item_id) REFERENCES wb_day_items(day_item_id) ON DELETE CASCADE,
  CONSTRAINT fk_wb_item_rule_rule FOREIGN KEY (rule_code) REFERENCES wb_selection_rules(rule_code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* ---------------------------------------------------------
   5) Confusing pairs guard
   --------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS wb_confusing_pairs (
  pair_id              INT AUTO_INCREMENT PRIMARY KEY,
  lexeme_id_a          INT NOT NULL,
  lexeme_id_b          INT NOT NULL,
  reason               VARCHAR(255),
  UNIQUE KEY uq_wb_confusing_pair (lexeme_id_a, lexeme_id_b),
  CONSTRAINT fk_wb_confusing_a FOREIGN KEY (lexeme_id_a) REFERENCES wb_lexemes(lexeme_id) ON DELETE CASCADE,
  CONSTRAINT fk_wb_confusing_b FOREIGN KEY (lexeme_id_b) REFERENCES wb_lexemes(lexeme_id) ON DELETE CASCADE,
  CONSTRAINT chk_wb_confusing_order CHECK (lexeme_id_a < lexeme_id_b)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* ---------------------------------------------------------
   6) Useful views
   --------------------------------------------------------- */
DROP VIEW IF EXISTS v_wb_day_cards;
CREATE VIEW v_wb_day_cards AS
SELECT
  t.track_name,
  d.day_no,
  d.theme,
  d.cefr_tag,
  d.actfl_tag,
  i.sort_no,
  l.lexeme_id,
  l.headword,
  l.ipa_us,
  l.ipa_uk,
  l.pos,
  l.core_meaning_en,
  l.core_meaning_ko,
  (
    SELECT GROUP_CONCAT(CONCAT(x.derivative_word, ' (', x.derivative_pos, ')') ORDER BY x.sort_no SEPARATOR ' | ')
    FROM wb_derivatives x
    WHERE x.lexeme_id = l.lexeme_id
  ) AS derivatives,
  (
    SELECT GROUP_CONCAT(c.collocation ORDER BY c.sort_no SEPARATOR ' | ')
    FROM wb_collocations c
    WHERE c.lexeme_id = l.lexeme_id
  ) AS collocations,
  (
    SELECT GROUP_CONCAT(e.sentence ORDER BY e.sort_no SEPARATOR ' || ')
    FROM wb_examples e
    WHERE e.lexeme_id = l.lexeme_id
  ) AS examples
FROM wb_day_items i
JOIN wb_days d ON d.day_id = i.day_id
JOIN wb_tracks t ON t.track_id = d.track_id
JOIN wb_lexemes l ON l.lexeme_id = i.lexeme_id;

DROP VIEW IF EXISTS v_wb_day_quality_summary;
CREATE VIEW v_wb_day_quality_summary AS
SELECT
  d.day_id,
  t.track_name,
  d.day_no,
  COUNT(i.day_item_id) AS items_count,
  SUM(CASE WHEN rc.passed = 0 THEN 1 ELSE 0 END) AS failed_rule_checks
FROM wb_days d
JOIN wb_tracks t ON t.track_id = d.track_id
LEFT JOIN wb_day_items i ON i.day_id = d.day_id
LEFT JOIN wb_day_item_rule_checks rc ON rc.day_item_id = i.day_item_id
GROUP BY d.day_id, t.track_name, d.day_no;

/* ---------------------------------------------------------
   7) Seed fixed 6 rules
   --------------------------------------------------------- */
INSERT INTO wb_selection_rules (rule_code, rule_name, description)
VALUES
('FREQUENCY', '빈도/범용성', '일상, 학교, 시험, 콘텐츠에서 자주 노출되는 단어인지 점검'),
('UTILITY', '기능성', '말하기/쓰기에서 즉시 사용 가능한지 점검(동사/형용사 우선)'),
('CORE_MEANING', '의미 핵심성', '초중급은 핵심 1~2 의미 위주로 제한'),
('COLLOCATION', '결합력', '대표 결합 표현이 명확한지 점검'),
('WORD_FAMILY', '확장성', '파생어 확장 학습이 가능한지 점검'),
('CONFUSION_RISK', '혼동 위험', '유사어 과밀 배치 여부 점검')
ON DUPLICATE KEY UPDATE
  rule_name = VALUES(rule_name),
  description = VALUES(description),
  is_active = 1;

/* ---------------------------------------------------------
   8) Sample: HighSchool_1 Bridge Day 1 (10 words)
   --------------------------------------------------------- */
INSERT INTO wb_tracks
  (track_name, target_grade, cefr_band_min, cefr_band_max, actfl_band_min, actfl_band_max, days_total)
VALUES
  ('HighSchool_1_365_Bridge', '고1', 'A2', 'B1+', 'Novice High', 'Intermediate Mid', 365)
ON DUPLICATE KEY UPDATE
  target_grade = VALUES(target_grade),
  cefr_band_min = VALUES(cefr_band_min),
  cefr_band_max = VALUES(cefr_band_max),
  actfl_band_min = VALUES(actfl_band_min),
  actfl_band_max = VALUES(actfl_band_max),
  days_total = VALUES(days_total);

INSERT INTO wb_days (track_id, day_no, theme, cefr_tag, actfl_tag, notes)
SELECT t.track_id, 1, '고1 브리지 Day 1: 학습/문제해결 핵심어휘', 'B1', 'Intermediate Mid', '하루 10개 고정'
FROM wb_tracks t
WHERE t.track_name='HighSchool_1_365_Bridge'
ON DUPLICATE KEY UPDATE
  theme = VALUES(theme),
  cefr_tag = VALUES(cefr_tag),
  actfl_tag = VALUES(actfl_tag),
  notes = VALUES(notes);

INSERT INTO wb_lexemes
  (headword, ipa_us, ipa_uk, pos, core_meaning_en, core_meaning_ko, cefr_tag, actfl_tag, utility_priority)
VALUES
('approach', '/əˈproʊtʃ/', '/əˈprəʊtʃ/', 'n., v.', 'a way of dealing with something; to move toward', '접근법; 접근하다', 'B1', 'Intermediate Mid', 'high'),
('assume', '/əˈsuːm/', '/əˈsjuːm/', 'v.', 'to think something is true without proof', '가정하다', 'B1', 'Intermediate Mid', 'high'),
('consume', '/kənˈsuːm/', '/kənˈsjuːm/', 'v.', 'to use up time, energy, or resources', '소비하다', 'B1', 'Intermediate Mid', 'high'),
('contribute', '/kənˈtrɪbjuːt/', '/kənˈtrɪbjuːt/', 'v.', 'to help cause or improve something', '기여하다', 'B1', 'Intermediate Mid', 'high'),
('define', '/dɪˈfaɪn/', '/dɪˈfaɪn/', 'v.', 'to explain exactly what something means', '정의하다', 'B1', 'Intermediate Mid', 'high'),
('evidence', '/ˈevɪdəns/', '/ˈevɪdəns/', 'n.', 'facts that show something is true', '증거', 'B1', 'Intermediate Mid', 'medium'),
('factor', '/ˈfæktər/', '/ˈfæktə/', 'n.', 'one of the reasons that influences a result', '요인', 'B1', 'Intermediate Mid', 'medium'),
('issue', '/ˈɪʃuː/', '/ˈɪʃuː/', 'n.', 'an important topic or problem', '문제, 쟁점', 'B1', 'Intermediate Mid', 'high'),
('occur', '/əˈkɜːr/', '/əˈkɜː/', 'v.', 'to happen; to come to mind', '발생하다; 떠오르다', 'B1', 'Intermediate Mid', 'medium'),
('respond', '/rɪˈspɑːnd/', '/rɪˈspɒnd/', 'v.', 'to answer or react', '반응하다, 응답하다', 'B1', 'Intermediate Mid', 'high')
ON DUPLICATE KEY UPDATE
  ipa_us = VALUES(ipa_us),
  ipa_uk = VALUES(ipa_uk),
  core_meaning_en = VALUES(core_meaning_en),
  core_meaning_ko = VALUES(core_meaning_ko),
  cefr_tag = VALUES(cefr_tag),
  actfl_tag = VALUES(actfl_tag),
  utility_priority = VALUES(utility_priority),
  is_active = 1;

INSERT INTO wb_derivatives (lexeme_id, derivative_word, derivative_pos, note, sort_no)
SELECT l.lexeme_id, x.derivative_word, x.derivative_pos, x.note, x.sort_no
FROM wb_lexemes l
JOIN (
  SELECT 'approach' AS headword, 'n., v.' AS pos, 'approachable' AS derivative_word, 'adj.' AS derivative_pos, '' AS note, 1 AS sort_no UNION ALL
  SELECT 'assume', 'v.', 'assumption', 'n.', '', 1 UNION ALL
  SELECT 'consume', 'v.', 'consumer', 'n.', '', 1 UNION ALL
  SELECT 'consume', 'v.', 'consumption', 'n.', '', 2 UNION ALL
  SELECT 'contribute', 'v.', 'contribution', 'n.', '', 1 UNION ALL
  SELECT 'define', 'v.', 'definition', 'n.', '', 1 UNION ALL
  SELECT 'define', 'v.', 'definite', 'adj.', '', 2 UNION ALL
  SELECT 'evidence', 'n.', 'evident', 'adj.', '', 1 UNION ALL
  SELECT 'evidence', 'n.', 'evidently', 'adv.', '', 2 UNION ALL
  SELECT 'factor', 'n.', 'factor in', 'phr.v.', '', 1 UNION ALL
  SELECT 'issue', 'n.', 'issue', 'v.', '발행하다(후속 단계)', 1 UNION ALL
  SELECT 'occur', 'v.', 'occurrence', 'n.', '', 1 UNION ALL
  SELECT 'respond', 'v.', 'response', 'n.', '', 1 UNION ALL
  SELECT 'respond', 'v.', 'responsive', 'adj.', '', 2
) x ON x.headword=l.headword AND x.pos=l.pos
ON DUPLICATE KEY UPDATE
  note = VALUES(note),
  sort_no = VALUES(sort_no);

INSERT INTO wb_collocations (lexeme_id, collocation, sort_no)
SELECT l.lexeme_id, x.collocation, 1
FROM wb_lexemes l
JOIN (
  SELECT 'approach' AS headword, 'n., v.' AS pos, 'an approach to ~' AS collocation UNION ALL
  SELECT 'assume', 'v.', 'assume that ~' UNION ALL
  SELECT 'consume', 'v.', 'consume energy/time' UNION ALL
  SELECT 'contribute', 'v.', 'contribute to ~' UNION ALL
  SELECT 'define', 'v.', 'define A as B' UNION ALL
  SELECT 'evidence', 'n.', 'strong evidence' UNION ALL
  SELECT 'factor', 'n.', 'a key factor' UNION ALL
  SELECT 'issue', 'n.', 'a social issue' UNION ALL
  SELECT 'occur', 'v.', 'occur to + person' UNION ALL
  SELECT 'respond', 'v.', 'respond to ~'
) x ON x.headword=l.headword AND x.pos=l.pos
ON DUPLICATE KEY UPDATE
  sort_no = VALUES(sort_no);

INSERT INTO wb_examples (lexeme_id, sentence, sentence_ko, sort_no)
SELECT l.lexeme_id, x.sentence, x.sentence_ko, 1
FROM wb_lexemes l
JOIN (
  SELECT 'approach' AS headword, 'n., v.' AS pos, 'We need a new approach to solving this problem.' AS sentence, '우리는 이 문제를 푸는 새로운 접근법이 필요하다.' AS sentence_ko UNION ALL
  SELECT 'assume', 'v.', 'Don''t assume that everyone agrees with you.', '모든 사람이 너에게 동의한다고 가정하지 마라.' UNION ALL
  SELECT 'consume', 'v.', 'Video games can consume a lot of time.', '비디오 게임은 많은 시간을 소비할 수 있다.' UNION ALL
  SELECT 'contribute', 'v.', 'Regular practice contributes to better results.', '규칙적인 연습은 더 나은 결과에 기여한다.' UNION ALL
  SELECT 'define', 'v.', 'The teacher defined the term in simple words.', '선생님은 그 용어를 쉬운 말로 정의했다.' UNION ALL
  SELECT 'evidence', 'n.', 'There is strong evidence that sleep helps memory.', '수면이 기억력에 도움이 된다는 강한 증거가 있다.' UNION ALL
  SELECT 'factor', 'n.', 'Motivation is a key factor in learning.', '동기는 학습의 핵심 요인이다.' UNION ALL
  SELECT 'issue', 'n.', 'Bullying is a serious issue at some schools.', '학교에서 괴롭힘은 심각한 문제다.' UNION ALL
  SELECT 'occur', 'v.', 'A good idea suddenly occurred to me.', '좋은 아이디어가 갑자기 떠올랐다.' UNION ALL
  SELECT 'respond', 'v.', 'Students responded well to the new class rule.', '학생들은 새 학급 규칙에 잘 반응했다.'
) x ON x.headword=l.headword AND x.pos=l.pos
ON DUPLICATE KEY UPDATE
  sentence_ko = VALUES(sentence_ko),
  sort_no = VALUES(sort_no);

INSERT INTO wb_day_items (day_id, lexeme_id, sort_no, is_required)
SELECT d.day_id, l.lexeme_id, x.sort_no, 1
FROM wb_days d
JOIN wb_tracks t ON t.track_id=d.track_id AND t.track_name='HighSchool_1_365_Bridge'
JOIN (
  SELECT 1 AS sort_no, 'approach' AS headword, 'n., v.' AS pos UNION ALL
  SELECT 2, 'assume', 'v.' UNION ALL
  SELECT 3, 'consume', 'v.' UNION ALL
  SELECT 4, 'contribute', 'v.' UNION ALL
  SELECT 5, 'define', 'v.' UNION ALL
  SELECT 6, 'evidence', 'n.' UNION ALL
  SELECT 7, 'factor', 'n.' UNION ALL
  SELECT 8, 'issue', 'n.' UNION ALL
  SELECT 9, 'occur', 'v.' UNION ALL
  SELECT 10, 'respond', 'v.'
) x ON 1=1
JOIN wb_lexemes l ON l.headword=x.headword AND l.pos=x.pos
WHERE d.day_no=1
ON DUPLICATE KEY UPDATE
  sort_no = VALUES(sort_no),
  is_required = VALUES(is_required);

/* ---------------------------------------------------------
   9) Quality check query snippets
   --------------------------------------------------------- */
-- A. day별 단어 수가 10개인지 확인
-- SELECT t.track_name, d.day_no, COUNT(i.day_item_id) AS item_count
-- FROM wb_days d
-- JOIN wb_tracks t ON t.track_id=d.track_id
-- LEFT JOIN wb_day_items i ON i.day_id=d.day_id
-- GROUP BY t.track_name, d.day_no
-- HAVING COUNT(i.day_item_id) <> 10;

-- B. 혼동어쌍이 같은 day에 동시에 들어갔는지 확인
-- SELECT t.track_name, d.day_no, la.headword AS word_a, lb.headword AS word_b, cp.reason
-- FROM wb_confusing_pairs cp
-- JOIN wb_day_items ia ON ia.lexeme_id=cp.lexeme_id_a
-- JOIN wb_day_items ib ON ib.lexeme_id=cp.lexeme_id_b AND ib.day_id=ia.day_id
-- JOIN wb_days d ON d.day_id=ia.day_id
-- JOIN wb_tracks t ON t.track_id=d.track_id
-- JOIN wb_lexemes la ON la.lexeme_id=cp.lexeme_id_a
-- JOIN wb_lexemes lb ON lb.lexeme_id=cp.lexeme_id_b
-- ORDER BY t.track_name, d.day_no;

-- C. 카드 조회(하루치 10개)
-- SELECT * FROM v_wb_day_cards
-- WHERE track_name='HighSchool_1_365_Bridge' AND day_no=1
-- ORDER BY sort_no;
