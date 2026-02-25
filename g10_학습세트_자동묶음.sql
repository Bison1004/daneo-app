/* =========================================================
   ✅ Day별 “학습세트(=root 10단어 + 추천 파생어 미션)” 자동 묶음
   목표:
   1) day_words(오늘의 root 10단어) 기준으로
   2) word_family_edges로 연결된 파생어 중
      - is_derived=1 AND (CEFR <= B2) 우선
      - 주어진 개수만큼(기본 3개) 자동 추천
   3) 앱에서 바로 쓸 수 있는 "오늘의 파생어 미션" 생성

   구성:
   - day_word_sets: day_id별 세트 메타
   - day_word_set_items: root/derived 항목(학습 카드) 저장
   - day_derived_missions: 오늘의 파생어 미션(derived만) 저장
   ========================================================= */

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS day_derived_missions;
DROP TABLE IF EXISTS day_word_set_items;
DROP TABLE IF EXISTS day_word_sets;
SET FOREIGN_KEY_CHECKS=1;

/* ---------------------------------------------------------
   1) Set tables
--------------------------------------------------------- */
CREATE TABLE day_word_sets (
  set_id        INT AUTO_INCREMENT PRIMARY KEY,
  day_id        INT NOT NULL UNIQUE,
  title         VARCHAR(128) NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_dws_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE day_word_set_items (
  set_item_id   INT AUTO_INCREMENT PRIMARY KEY,
  set_id        INT NOT NULL,
  word_id       INT NOT NULL,
  item_type     ENUM('root','derived') NOT NULL,
  root_word_id  INT NULL,                 -- derived인 경우 어떤 root에서 왔는지
  sort_no       INT NOT NULL,
  UNIQUE KEY uq_set_word (set_id, word_id),
  UNIQUE KEY uq_set_sort (set_id, sort_no),
  CONSTRAINT fk_dws_item_set FOREIGN KEY (set_id) REFERENCES day_word_sets(set_id) ON DELETE CASCADE,
  CONSTRAINT fk_dws_item_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE,
  CONSTRAINT fk_dws_item_root FOREIGN KEY (root_word_id) REFERENCES words(word_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE day_derived_missions (
  mission_id    INT AUTO_INCREMENT PRIMARY KEY,
  day_id        INT NOT NULL,
  derived_word_id INT NOT NULL,
  root_word_id  INT NOT NULL,
  mission_type  ENUM('use_in_speaking','use_in_sentence','collocation_focus') NOT NULL DEFAULT 'use_in_speaking',
  difficulty_tag VARCHAR(16) DEFAULT 'B1',
  sort_no       INT NOT NULL,
  UNIQUE KEY uq_day_mission_sort (day_id, sort_no),
  UNIQUE KEY uq_day_derived (day_id, derived_word_id),
  CONSTRAINT fk_ddm_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE,
  CONSTRAINT fk_ddm_derived FOREIGN KEY (derived_word_id) REFERENCES words(word_id) ON DELETE CASCADE,
  CONSTRAINT fk_ddm_root FOREIGN KEY (root_word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;


/* ---------------------------------------------------------
   2) Set 생성: HS1 Week1 Day1~Day7
--------------------------------------------------------- */
INSERT INTO day_word_sets (day_id, title)
SELECT d.day_id, CONCAT('HS1 W', d.week_no, ' D', d.day_no, ' Learning Set')
FROM days d
WHERE d.grade='HighSchool_1' AND d.week_no=1
ON DUPLICATE KEY UPDATE title=VALUES(title);


/* ---------------------------------------------------------
   3) Root 10단어를 Set Items로 삽입 (item_type='root')
   - sort_no는 day_words.sort_no를 그대로 사용
--------------------------------------------------------- */
INSERT INTO day_word_set_items (set_id, word_id, item_type, root_word_id, sort_no)
SELECT s.set_id, dw.word_id, 'root' AS item_type, NULL AS root_word_id, dw.sort_no AS sort_no
FROM day_word_sets s
JOIN days d ON d.day_id=s.day_id
JOIN day_words dw ON dw.day_id=d.day_id
WHERE d.grade='HighSchool_1' AND d.week_no=1
ON DUPLICATE KEY UPDATE sort_no=VALUES(sort_no);


/* ---------------------------------------------------------
   4) 파생어 추천 알고리즘(간단/실전형)
   - 각 day의 root 10단어로부터 파생어 후보를 뽑고
   - 우선순위:
       1) cefr B1, B1+, B2, A2+ 순(대략)
       2) freq_band(연어가 high인 파생어) 가산
       3) 너무 어려운 C1 이상은 제외(기본)
   - 오늘의 미션 개수: 3개(변경 가능)
--------------------------------------------------------- */

-- (A) 먼저 day_derived_missions 비우기(재생성 시)
DELETE m
FROM day_derived_missions m
JOIN days d ON d.day_id=m.day_id
WHERE d.grade='HighSchool_1' AND d.week_no=1;

-- (B) Day별 Top 3 파생어 미션 생성 (MySQL 8 윈도우 함수 사용)
WITH derived_candidates AS (
  SELECT
    d.day_id,
    e.root_word_id,
    e.derived_word_id,
    dw.sort_no AS root_sort,
    COALESCE(der.cefr,'B2') AS derived_cefr,
    -- 연어 high 개수(있으면 가산)
    (SELECT COUNT(*) FROM word_collocations wc
      WHERE wc.word_id=e.derived_word_id AND wc.freq_band='high') AS high_col_cnt,
    -- CEFR 우선순위 점수(낮을수록 우선)
    CASE COALESCE(der.cefr,'B2')
      WHEN 'A2'  THEN 5
      WHEN 'A2+' THEN 4
      WHEN 'B1'  THEN 1
      WHEN 'B1+' THEN 2
      WHEN 'B2'  THEN 3
      ELSE 9
    END AS cefr_rank
  FROM days d
  JOIN day_words dw ON dw.day_id=d.day_id
  JOIN word_family_edges e ON e.root_word_id=dw.word_id
  JOIN words der ON der.word_id=e.derived_word_id
  WHERE d.grade='HighSchool_1' AND d.week_no=1
    AND der.is_derived=1
    AND COALESCE(der.cefr,'B2') NOT IN ('C1','C2')
),
ranked AS (
  SELECT
    dc.*,
    ROW_NUMBER() OVER (
      PARTITION BY dc.day_id
      ORDER BY
        dc.cefr_rank ASC,
        dc.high_col_cnt DESC,
        dc.root_sort ASC,
        dc.derived_word_id ASC
    ) AS rn
  FROM derived_candidates dc
)
INSERT INTO day_derived_missions (day_id, derived_word_id, root_word_id, mission_type, difficulty_tag, sort_no)
SELECT
  r.day_id,
  r.derived_word_id,
  r.root_word_id,
  'use_in_speaking' AS mission_type,
  COALESCE(r.derived_cefr,'B1') AS difficulty_tag,
  r.rn AS sort_no
FROM ranked r
WHERE r.rn <= 3;


-- (C) 파생어도 Set Items로 넣기 (root 10개 다음부터 sort_no 이어붙임)
--     - sort_no = 10 + mission.sort_no (Day1 기준 root 10개)
INSERT INTO day_word_set_items (set_id, word_id, item_type, root_word_id, sort_no)
SELECT
  s.set_id,
  m.derived_word_id AS word_id,
  'derived' AS item_type,
  m.root_word_id,
  10 + m.sort_no AS sort_no
FROM day_word_sets s
JOIN day_derived_missions m ON m.day_id=s.day_id
JOIN days d ON d.day_id=s.day_id
WHERE d.grade='HighSchool_1' AND d.week_no=1
ON DUPLICATE KEY UPDATE
  root_word_id=VALUES(root_word_id),
  sort_no=VALUES(sort_no);


/* ---------------------------------------------------------
   5) “파생어 미션 타입”을 다양화(선택)
   - 미션 3개 중 1개는 collocation_focus로 바꾸고 싶다면:
--------------------------------------------------------- */
UPDATE day_derived_missions
SET mission_type='collocation_focus'
WHERE mission_type='use_in_speaking'
  AND sort_no=2
  AND day_id IN (SELECT day_id FROM days WHERE grade='HighSchool_1' AND week_no=1);


/* =========================================================
   ✅ 조회용 VIEW: Day 학습세트(루트+파생+카드정보)
   ========================================================= */

DROP VIEW IF EXISTS v_day_learning_set;
CREATE VIEW v_day_learning_set AS
SELECT
  d.grade, d.week_no, d.day_no,
  s.set_id,
  i.sort_no,
  i.item_type,
  w.word_id, w.headword, w.pos, w.cefr, w.is_derived,
  w.definition_simple,
  i.root_word_id,
  rw.headword AS from_root
FROM day_word_sets s
JOIN days d ON d.day_id=s.day_id
JOIN day_word_set_items i ON i.set_id=s.set_id
JOIN words w ON w.word_id=i.word_id
LEFT JOIN words rw ON rw.word_id=i.root_word_id;


/* =========================================================
   ✅ 조회 예시
   ========================================================= */

-- (1) HS1 Week1 Day1 학습세트: root 10 + derived mission 3
SELECT *
FROM v_day_learning_set
WHERE grade='HighSchool_1' AND week_no=1 AND day_no=1
ORDER BY sort_no;

-- (2) Day별 파생어 미션 확인
SELECT d.day_no, m.sort_no, dw.headword AS derived_word, dw.pos, m.mission_type, rw.headword AS from_root, dw.cefr
FROM day_derived_missions m
JOIN days d ON d.day_id=m.day_id
JOIN words dw ON dw.word_id=m.derived_word_id
JOIN words rw ON rw.word_id=m.root_word_id
WHERE d.grade='HighSchool_1' AND d.week_no=1
ORDER BY d.day_no, m.sort_no;

-- (3) 특정 Day의 “파생어 미션 카드”를 v_word_learning_card로 함께 보기(예: Day1)
-- SELECT c.* FROM v_word_learning_card c
-- JOIN day_derived_missions m ON m.derived_word_id=c.word_id
-- JOIN days d ON d.day_id=m.day_id
-- WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=1;