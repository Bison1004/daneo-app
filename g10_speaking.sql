/* =========================================================
   HS1 (수능+말하기) Week1 Day1~Day7 SQL (MySQL 8+ 기준)
   - UTF8MB4 권장
   - 핵심: Day(학습일) ↔ Word(단어) 다대다 + Pattern/Task/Checklist
   ========================================================= */

-- 0) DB 권장 설정
-- CREATE DATABASE efl_vocab_app CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- USE efl_vocab_app;

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS day_checklist_collocations;
DROP TABLE IF EXISTS day_checklist_connectors;
DROP TABLE IF EXISTS day_checklists;
DROP TABLE IF EXISTS speaking_tasks;
DROP TABLE IF EXISTS day_patterns;
DROP TABLE IF EXISTS patterns;
DROP TABLE IF EXISTS example_sentences;
DROP TABLE IF EXISTS word_collocations;
DROP TABLE IF EXISTS word_synonyms;
DROP TABLE IF EXISTS word_family;
DROP TABLE IF EXISTS day_words;
DROP TABLE IF EXISTS words;
DROP TABLE IF EXISTS days;

SET FOREIGN_KEY_CHECKS=1;

-- 1) Days
CREATE TABLE days (
  day_id        INT AUTO_INCREMENT PRIMARY KEY,
  grade         VARCHAR(32) NOT NULL,           -- HighSchool_1
  week_no       INT NOT NULL,
  day_no        INT NOT NULL,                   -- 1..7
  theme         VARCHAR(128) NOT NULL,
  focus         VARCHAR(128) NOT NULL,
  target_cefr   VARCHAR(16),
  target_actfl  VARCHAR(32),
  lexile_band   VARCHAR(32),
  UNIQUE KEY uq_day (grade, week_no, day_no)
) ENGINE=InnoDB;

-- 2) Words
CREATE TABLE words (
  word_id            INT AUTO_INCREMENT PRIMARY KEY,
  headword           VARCHAR(64) NOT NULL,
  pos                VARCHAR(32) NOT NULL,       -- v/n/adj/etc
  cefr               VARCHAR(16),
  definition_simple  VARCHAR(255) NOT NULL,
  UNIQUE KEY uq_headword_pos (headword, pos)
) ENGINE=InnoDB;

-- 3) Day-Words (10단어/일)
CREATE TABLE day_words (
  day_id  INT NOT NULL,
  word_id INT NOT NULL,
  sort_no INT NOT NULL,                           -- 1..10
  PRIMARY KEY (day_id, word_id),
  UNIQUE KEY uq_day_sort (day_id, sort_no),
  CONSTRAINT fk_dw_day  FOREIGN KEY (day_id)  REFERENCES days(day_id)  ON DELETE CASCADE,
  CONSTRAINT fk_dw_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4) Word Family
CREATE TABLE word_family (
  family_id    INT AUTO_INCREMENT PRIMARY KEY,
  word_id      INT NOT NULL,                      -- root/headword의 word_id
  derived_word VARCHAR(64) NOT NULL,
  derived_pos  VARCHAR(32),
  derived_cefr VARCHAR(16),
  CONSTRAINT fk_wf_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5) Synonyms (레벨/뉘앙스)
CREATE TABLE word_synonyms (
  syn_id        INT AUTO_INCREMENT PRIMARY KEY,
  word_id       INT NOT NULL,
  synonym_word  VARCHAR(64) NOT NULL,
  nuance_level  INT NOT NULL DEFAULT 1,          -- 1(쉬움)~3(고급)
  CONSTRAINT fk_ws_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6) Collocations
CREATE TABLE word_collocations (
  col_id        INT AUTO_INCREMENT PRIMARY KEY,
  word_id       INT NOT NULL,
  collocation   VARCHAR(128) NOT NULL,
  freq_band     VARCHAR(16) DEFAULT 'high',      -- high/medium/low
  CONSTRAINT fk_wc_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7) Example Sentences
CREATE TABLE example_sentences (
  ex_id     INT AUTO_INCREMENT PRIMARY KEY,
  word_id   INT NOT NULL,
  ex_type   ENUM('reading','speaking') NOT NULL,
  sentence  VARCHAR(255) NOT NULL,
  CONSTRAINT fk_ex_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8) Patterns
CREATE TABLE patterns (
  pattern_id    VARCHAR(16) PRIMARY KEY,         -- P01...
  structure     VARCHAR(128) NOT NULL,
  level_tag     VARCHAR(16) NOT NULL,            -- A2/B1...
  example       VARCHAR(255)
) ENGINE=InnoDB;

-- 9) Day-Patterns
CREATE TABLE day_patterns (
  day_id     INT NOT NULL,
  pattern_id VARCHAR(16) NOT NULL,
  sort_no    INT NOT NULL,                        -- 1..2
  PRIMARY KEY (day_id, pattern_id),
  UNIQUE KEY uq_dp_day_sort (day_id, sort_no),
  CONSTRAINT fk_dp_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE,
  CONSTRAINT fk_dp_pat FOREIGN KEY (pattern_id) REFERENCES patterns(pattern_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10) Speaking Task
CREATE TABLE speaking_tasks (
  task_id               INT AUTO_INCREMENT PRIMARY KEY,
  day_id                INT NOT NULL UNIQUE,
  prompt                VARCHAR(255) NOT NULL,
  target_words_min      INT NOT NULL,
  recommended_time_sec  INT NOT NULL,
  CONSTRAINT fk_task_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 11) Checklist (하루 채점 규칙)
CREATE TABLE day_checklists (
  checklist_id      INT AUTO_INCREMENT PRIMARY KEY,
  day_id            INT NOT NULL UNIQUE,
  target_hits_min   INT NOT NULL,
  target_hits_max   INT NOT NULL,
  points_vocab      INT NOT NULL,
  family_bonus_on   TINYINT(1) NOT NULL DEFAULT 1,
  points_family     INT NOT NULL,
  min_words         INT NOT NULL,
  min_sentences     INT NOT NULL,
  CONSTRAINT fk_chk_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE day_checklist_collocations (
  checklist_id INT NOT NULL,
  collocation  VARCHAR(128) NOT NULL,
  PRIMARY KEY (checklist_id, collocation),
  CONSTRAINT fk_chkc_chk FOREIGN KEY (checklist_id) REFERENCES day_checklists(checklist_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE day_checklist_connectors (
  checklist_id INT NOT NULL,
  connector    VARCHAR(32) NOT NULL,
  PRIMARY KEY (checklist_id, connector),
  CONSTRAINT fk_chkn_chk FOREIGN KEY (checklist_id) REFERENCES day_checklists(checklist_id) ON DELETE CASCADE
) ENGINE=InnoDB;


/* =========================================================
   INSERT: Days (Week1 Day1~Day7)
   ========================================================= */
INSERT INTO days (grade, week_no, day_no, theme, focus, target_cefr, target_actfl, lexile_band) VALUES
('HighSchool_1', 1, 1, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'cause-effect basics', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 2, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'problem-solution + prevention', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 3, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'evidence + claims (Suneung logic)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 4, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'process & steps (speaking clarity)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 5, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'comparison (Suneung frequent)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 6, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'opinion + reason + example (speaking core)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 7, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'mini debate (counterargument)', 'A2+~B1', 'Intermediate Mid', '950~1100L');

-- 편의를 위해 day_id 조회 (MySQL에서는 아래 SELECT로 확인)
-- SELECT day_id, day_no FROM days WHERE grade='HighSchool_1' AND week_no=1 ORDER BY day_no;


/* =========================================================
   INSERT: Patterns (P01~P14)
   ========================================================= */
INSERT INTO patterns (pattern_id, structure, level_tag, example) VALUES
('P01','A causes B.','A2','Lack of sleep causes stress.'),
('P02','A has a (positive/negative) effect on B.','B1','Exercise has a positive effect on mood.'),
('P03','One problem is that ~.','A2+','One problem is that students sleep too late.'),
('P04','A possible solution is to ~.','A2+','A possible solution is to set a fixed bedtime.'),
('P05','There is evidence that ~.','B1','There is evidence that sleep improves memory.'),
('P06','This suggests/indicates that ~.','B1','This indicates that we should rest more.'),
('P07','First, ~. Next, ~. Finally, ~.','A2+','First, review. Next, practice. Finally, record your speaking.'),
('P08','To ~, you need to ~.','A2+','To improve speaking, you need to practice consistently.'),
('P09','Compared to A, B is ~.','B1','Compared to late-night study, morning study is more efficient.'),
('P10','One advantage/disadvantage of A is that ~.','B1','One disadvantage of phones is that they distract students.'),
('P11','In my opinion, ~.','A2+','In my opinion, daily practice is essential.'),
('P12','One reason is that ~. For example, ~.','B1','One reason is that habits save time. For example, I review every night.'),
('P13','Some people argue that ~. However, ~.','B1','Some people argue that phones help learning. However, they can distract students.'),
('P14','Although ~, ~.','B1','Although homework is necessary, too much can increase stress.');


/* =========================================================
   INSERT: Words (Day1~Day7 사용 단어)
   - 중복 단어는 1회만 insert. (uq_headword_pos)
   ========================================================= */

-- Day 1 words
INSERT INTO words (headword, pos, cefr, definition_simple) VALUES
('cause','v/n','A2','to make something happen; the reason something happens'),
('effect','n','A2','a result or change caused by something'),
('affect','v','B1','to change or influence something'),
('result','n/v','A2','something that happens because of something else'),
('factor','n','B1','one important part that influences a situation'),
('increase','v/n','A2','to become larger or greater'),
('reduce','v','B1','to make something smaller or less'),
('require','v','B1','to need something; to make something necessary'),
('solution','n','B1','a way to solve a problem');

-- Day 2 words (새 단어만)
INSERT INTO words (headword, pos, cefr, definition_simple) VALUES
('issue','n','B1','an important problem or topic'),
('challenge','n','B1','something difficult that tests you'),
('prevent','v','B1','to stop something from happening'),
('avoid','v','A2','to stay away from; not do something'),
('manage','v','B1','to control or handle something'),
('support','v/n','A2+','to help; help given'),
('suggest','v','B1','to recommend an idea'),
('strategy','n','B1','a plan to achieve a goal'),
('risk','n','B1','the chance of something bad happening'),
('benefit','n/v','B1','a good result; to help');

-- Day 3 words (새 단어만)
INSERT INTO words (headword, pos, cefr, definition_simple) VALUES
('evidence','n','B1','facts or signs that show something is true'),
('claim','n/v','B1','to say something is true; a statement'),
('argue','v','B1','to give reasons for your opinion'),
('conclude','v','B1','to decide after thinking; to end'),
('indicate','v','B1','to show or suggest'),
('research','n/v','B1','careful study to discover facts'),
('data','n','B1','information, often numbers, used for analysis'),
('trend','n','B1','a general direction of change');

-- Day 4 words (새 단어만)
INSERT INTO words (headword, pos, cefr, definition_simple) VALUES
('process','n','B1','a series of actions to achieve a result'),
('method','n','B1','a way of doing something'),
('step','n','A2','one action in a process'),
('practice','n/v','A2','to do something repeatedly to improve'),
('improve','v','A2','to make something better'),
('maintain','v','B1','to keep something at the same level'),
('focus','v/n','A2+','to pay attention to one thing'),
('review','v/n','B1','to look at something again to remember it'),
('consistency','n','B1','doing something in the same way regularly'),
('goal','n','A2','something you want to achieve');

-- Day 5 words (새 단어만)
INSERT INTO words (headword, pos, cefr, definition_simple) VALUES
('compare','v','A2+','to look at similarities and differences'),
('contrast','v/n','B1','to show differences clearly'),
('similar','adj','A2','almost the same'),
('different','adj','A1','not the same'),
('advantage','n','B1','a good point or benefit'),
('disadvantage','n','B1','a bad point'),
('prefer','v','A2','to like one thing more than another'),
('option','n','A2','a choice'),
('balance','n/v','B1','a healthy mix; to keep things equal'),
('efficient','adj','B1','working well without wasting time or energy');

-- Day 6 words (새 단어만)
INSERT INTO words (headword, pos, cefr, definition_simple) VALUES
('opinion','n','A2+','what you think or believe'),
('reason','n','A2','a cause or explanation'),
('example','n','A2','something that shows what you mean'),
('explain','v','A2+','to make something clear'),
('recommend','v','B1','to suggest something as good'),
('decide','v','A2','to choose after thinking'),
('pressure','n','B1','stress or force from expectations'),
('motivate','v','B1','to make someone want to do something'),
('confidence','n','B1','belief that you can do something well'),
('habit','n','A2+','something you do regularly');

-- Day 7 words (새 단어만)
INSERT INTO words (headword, pos, cefr, definition_simple) VALUES
('agree','v','A2','to have the same opinion'),
('disagree','v','A2+','to have a different opinion'),
('however','adv','B1','used to show a contrast'),
('although','conj','B1','used to introduce a contrast'),
('consider','v','B1','to think carefully about'),
('perspective','n','B1+','a way of thinking about something'),
('limit','v/n','B1','to control the size or amount; a maximum amount'),
('necessary','adj','A2+','needed; important'),
('effective','adj','B1','working well and producing results');


/* =========================================================
   INSERT: Day-Words (Day1~Day7, 각 10개)
   - 아래는 headword+pos 로 word_id를 찾아 연결
   ========================================================= */

-- Day1: 9개(샘플에서 10개 중 9개만 넣었으므로, 필요하면 day1에 10번째 단어 추가 가능)
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 sort_no, 'cause' headword, 'v/n' pos UNION ALL
  SELECT 2, 'effect','n' UNION ALL
  SELECT 3, 'affect','v' UNION ALL
  SELECT 4, 'result','n/v' UNION ALL
  SELECT 5, 'factor','n' UNION ALL
  SELECT 6, 'increase','v/n' UNION ALL
  SELECT 7, 'reduce','v' UNION ALL
  SELECT 8, 'require','v' UNION ALL
  SELECT 9, 'solution','n'
) x
JOIN words w ON w.headword=x.headword AND w.pos=x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=1;

-- Day2
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 sort_no,'issue' headword,'n' pos UNION ALL
  SELECT 2,'challenge','n' UNION ALL
  SELECT 3,'prevent','v' UNION ALL
  SELECT 4,'avoid','v' UNION ALL
  SELECT 5,'manage','v' UNION ALL
  SELECT 6,'support','v/n' UNION ALL
  SELECT 7,'suggest','v' UNION ALL
  SELECT 8,'strategy','n' UNION ALL
  SELECT 9,'risk','n' UNION ALL
  SELECT 10,'benefit','n/v'
) x
JOIN words w ON w.headword=x.headword AND w.pos=x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=2;

-- Day3
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 sort_no,'evidence' headword,'n' pos UNION ALL
  SELECT 2,'claim','n/v' UNION ALL
  SELECT 3,'argue','v' UNION ALL
  SELECT 4,'support','v/n' UNION ALL
  SELECT 5,'conclude','v' UNION ALL
  SELECT 6,'indicate','v' UNION ALL
  SELECT 7,'research','n/v' UNION ALL
  SELECT 8,'data','n' UNION ALL
  SELECT 9,'trend','n'
) x
JOIN words w ON w.headword=x.headword AND w.pos=x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=3;

-- Day4
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 sort_no,'process' headword,'n' pos UNION ALL
  SELECT 2,'method','n' UNION ALL
  SELECT 3,'step','n' UNION ALL
  SELECT 4,'practice','n/v' UNION ALL
  SELECT 5,'improve','v' UNION ALL
  SELECT 6,'maintain','v' UNION ALL
  SELECT 7,'focus','v/n' UNION ALL
  SELECT 8,'review','v/n' UNION ALL
  SELECT 9,'consistency','n' UNION ALL
  SELECT 10,'goal','n'
) x
JOIN words w ON w.headword=x.headword AND w.pos=x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=4;

-- Day5
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 sort_no,'compare' headword,'v' pos UNION ALL
  SELECT 2,'contrast','v/n' UNION ALL
  SELECT 3,'similar','adj' UNION ALL
  SELECT 4,'different','adj' UNION ALL
  SELECT 5,'advantage','n' UNION ALL
  SELECT 6,'disadvantage','n' UNION ALL
  SELECT 7,'prefer','v' UNION ALL
  SELECT 8,'option','n' UNION ALL
  SELECT 9,'balance','n/v' UNION ALL
  SELECT 10,'efficient','adj'
) x
JOIN words w ON w.headword=x.headword AND w.pos=x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=5;

-- Day6
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 sort_no,'opinion' headword,'n' pos UNION ALL
  SELECT 2,'reason','n' UNION ALL
  SELECT 3,'example','n' UNION ALL
  SELECT 4,'explain','v' UNION ALL
  SELECT 5,'recommend','v' UNION ALL
  SELECT 6,'decide','v' UNION ALL
  SELECT 7,'pressure','n' UNION ALL
  SELECT 8,'motivate','v' UNION ALL
  SELECT 9,'confidence','n' UNION ALL
  SELECT 10,'habit','n'
) x
JOIN words w ON w.headword=x.headword AND w.pos=x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=6;

-- Day7
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 sort_no,'argue' headword,'v' pos UNION ALL
  SELECT 2,'agree','v' UNION ALL
  SELECT 3,'disagree','v' UNION ALL
  SELECT 4,'however','adv' UNION ALL
  SELECT 5,'although','conj' UNION ALL
  SELECT 6,'consider','v' UNION ALL
  SELECT 7,'perspective','n' UNION ALL
  SELECT 8,'limit','v/n' UNION ALL
  SELECT 9,'necessary','adj' UNION ALL
  SELECT 10,'effective','adj'
) x
JOIN words w ON w.headword=x.headword AND w.pos=x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=7;


/* =========================================================
   INSERT: Word Family (핵심 파생어만 샘플)
   ========================================================= */
INSERT INTO word_family (word_id, derived_word, derived_pos, derived_cefr)
SELECT w.word_id, f.derived_word, f.derived_pos, f.derived_cefr
FROM words w
JOIN (
  SELECT 'cause' headword,'v/n' pos,'causal' derived_word,'adj' derived_pos,'B1' derived_cefr UNION ALL
  SELECT 'cause','v/n','causation','n','B2' UNION ALL
  SELECT 'effect','n','effective','adj','B1' UNION ALL
  SELECT 'effect','n','effectively','adv','B1' UNION ALL
  SELECT 'effect','n','affect','v','B1' UNION ALL
  SELECT 'increase','v/n','increasing','adj','B1' UNION ALL
  SELECT 'increase','v/n','increasingly','adv','B1' UNION ALL
  SELECT 'reduce','v','reduction','n','B1' UNION ALL
  SELECT 'require','v','requirement','n','B1' UNION ALL
  SELECT 'solution','n','solve','v','B1' UNION ALL
  SELECT 'suggest','v','suggestion','n','B1' UNION ALL
  SELECT 'strategy','n','strategic','adj','B2' UNION ALL
  SELECT 'evidence','n','evident','adj','B1' UNION ALL
  SELECT 'evidence','n','evidently','adv','B2' UNION ALL
  SELECT 'claim','n/v','claimed','adj','B1' UNION ALL
  SELECT 'argue','v','argument','n','B1' UNION ALL
  SELECT 'conclude','v','conclusion','n','B1' UNION ALL
  SELECT 'indicate','v','indication','n','B1' UNION ALL
  SELECT 'research','n/v','researcher','n','B1' UNION ALL
  SELECT 'process','n','processing','n/adj','B1' UNION ALL
  SELECT 'practice','n/v','practical','adj','B1' UNION ALL
  SELECT 'improve','v','improvement','n','B1' UNION ALL
  SELECT 'maintain','v','maintenance','n','B2' UNION ALL
  SELECT 'focus','v/n','focused','adj','B1' UNION ALL
  SELECT 'review','v/n','revise','v','B1' UNION ALL
  SELECT 'consistency','n','consistent','adj','B1' UNION ALL
  SELECT 'efficient','adj','efficiency','n','B1' UNION ALL
  SELECT 'efficient','adj','efficiently','adv','B1' UNION ALL
  SELECT 'recommend','v','recommendation','n','B1' UNION ALL
  SELECT 'decide','v','decision','n','B1' UNION ALL
  SELECT 'motivate','v','motivation','n','B1' UNION ALL
  SELECT 'confidence','n','confident','adj','B1' UNION ALL
  SELECT 'habit','n','habitual','adj','B2' UNION ALL
  SELECT 'agree','v','agreement','n','B1' UNION ALL
  SELECT 'disagree','v','disagreement','n','B1' UNION ALL
  SELECT 'limit','v/n','limitation','n','B2' UNION ALL
  SELECT 'necessary','adj','necessity','n','B2'
) f
ON w.headword=f.headword AND w.pos=f.pos;

--  (원하시면 동의어/연어/예문도 Day1~Day7 전부 INSERT로 확장해 드릴 수 있어요.)


/* =========================================================
   INSERT: Day-Patterns (각 2개)
   ========================================================= */
INSERT INTO day_patterns (day_id, pattern_id, sort_no)
SELECT d.day_id, x.pattern_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 day_no, 1 sort_no, 'P01' pattern_id UNION ALL
  SELECT 1, 2, 'P02' UNION ALL
  SELECT 2, 1, 'P03' UNION ALL
  SELECT 2, 2, 'P04' UNION ALL
  SELECT 3, 1, 'P05' UNION ALL
  SELECT 3, 2, 'P06' UNION ALL
  SELECT 4, 1, 'P07' UNION ALL
  SELECT 4, 2, 'P08' UNION ALL
  SELECT 5, 1, 'P09' UNION ALL
  SELECT 5, 2, 'P10' UNION ALL
  SELECT 6, 1, 'P11' UNION ALL
  SELECT 6, 2, 'P12' UNION ALL
  SELECT 7, 1, 'P13' UNION ALL
  SELECT 7, 2, 'P14'
) x ON x.day_no=d.day_no
WHERE d.grade='HighSchool_1' AND d.week_no=1;


/* =========================================================
   INSERT: Speaking Tasks (Day1~Day7)
   ========================================================= */
INSERT INTO speaking_tasks (day_id, prompt, target_words_min, recommended_time_sec)
SELECT d.day_id, t.prompt, t.target_words_min, t.recommended_time_sec
FROM days d
JOIN (
  SELECT 1 day_no,
         'What causes students to feel stressed at school? Explain one main cause and one effect. Give one solution.' prompt,
         5 target_words_min, 60 recommended_time_sec
  UNION ALL SELECT 2,
         'Choose one school issue (sleep, phone use, or homework). Describe the problem, explain one risk, and suggest one strategy to prevent it.',
         5, 60
  UNION ALL SELECT 3,
         'Make one claim about studying (sleep, review, or phone use). Give evidence (a fact, research, or personal example), and conclude your opinion.',
         5, 70
  UNION ALL SELECT 4,
         'Explain your study process in three steps. Include one method you use to maintain consistency and reach your goal.',
         5, 60
  UNION ALL SELECT 5,
         'Compare online learning and offline learning. Mention one advantage and one disadvantage, and say which you prefer and why.',
         5, 70
  UNION ALL SELECT 6,
         'In your opinion, what is the best way to improve English speaking? Give one reason and one example, and recommend a habit.',
         5, 75
  UNION ALL SELECT 7,
         'Topic: Smartphones in school. Present one argument for, one argument against, and your final opinion. Use however/although at least once.',
         5, 80
) t ON t.day_no=d.day_no
WHERE d.grade='HighSchool_1' AND d.week_no=1;


/* =========================================================
   INSERT: Checklists (Day1~Day7)
   ========================================================= */
INSERT INTO day_checklists (day_id, target_hits_min, target_hits_max, points_vocab, family_bonus_on, points_family, min_words, min_sentences)
SELECT d.day_id, c.target_hits_min, c.target_hits_max, c.points_vocab, c.family_bonus_on, c.points_family, c.min_words, c.min_sentences
FROM days d
JOIN (
  SELECT 1 day_no, 5 target_hits_min, 10 target_hits_max, 25 points_vocab, 1 family_bonus_on, 10 points_family, 45 min_words, 3 min_sentences UNION ALL
  SELECT 2, 5, 10, 25, 1, 10, 45, 3 UNION ALL
  SELECT 3, 5, 10, 25, 1, 10, 55, 4 UNION ALL
  SELECT 4, 5, 10, 25, 1, 10, 45, 3 UNION ALL
  SELECT 5, 5, 10, 25, 1, 10, 55, 4 UNION ALL
  SELECT 6, 5, 10, 25, 1, 10, 60, 4 UNION ALL
  SELECT 7, 5, 10, 25, 1, 10, 65, 5
) c ON c.day_no=d.day_no
WHERE d.grade='HighSchool_1' AND d.week_no=1;

-- Checklist Collocations (Day1~Day7)
INSERT INTO day_checklist_collocations (checklist_id, collocation)
SELECT chk.checklist_id, x.collocation
FROM day_checklists chk
JOIN days d ON d.day_id=chk.day_id
JOIN (
  SELECT 1 day_no, 'have an effect on' collocation UNION ALL
  SELECT 1, 'one key factor' UNION ALL
  SELECT 1, 'find a solution' UNION ALL
  SELECT 1, 'reduce stress' UNION ALL

  SELECT 2, 'reduce the risk' UNION ALL
  SELECT 2, 'benefit from' UNION ALL
  SELECT 2, 'effective strategy' UNION ALL
  SELECT 2, 'prevent distractions' UNION ALL

  SELECT 3, 'strong evidence' UNION ALL
  SELECT 3, 'make a claim' UNION ALL
  SELECT 3, 'reach a conclusion' UNION ALL
  SELECT 3, 'results indicate that' UNION ALL

  SELECT 4, 'set a goal' UNION ALL
  SELECT 4, 'focus on' UNION ALL
  SELECT 4, 'weekly review' UNION ALL
  SELECT 4, 'practice consistently' UNION ALL

  SELECT 5, 'compared to' UNION ALL
  SELECT 5, 'one advantage of' UNION ALL
  SELECT 5, 'one disadvantage of' UNION ALL
  SELECT 5, 'balance A and B' UNION ALL

  SELECT 6, 'in my opinion' UNION ALL
  SELECT 6, 'one reason is that' UNION ALL
  SELECT 6, 'for example' UNION ALL
  SELECT 6, 'make a decision' UNION ALL
  SELECT 6, 'build confidence' UNION ALL

  SELECT 7, 'some people argue that' UNION ALL
  SELECT 7, 'from my perspective' UNION ALL
  SELECT 7, 'set a limit' UNION ALL
  SELECT 7, 'effective way'
) x ON x.day_no=d.day_no;

-- Checklist Connectors (Day1~Day7)
INSERT INTO day_checklist_connectors (checklist_id, connector)
SELECT chk.checklist_id, x.connector
FROM day_checklists chk
JOIN days d ON d.day_id=chk.day_id
JOIN (
  SELECT 1 day_no, 'because' connector UNION ALL
  SELECT 1, 'so' UNION ALL
  SELECT 1, 'therefore' UNION ALL
  SELECT 1, 'as a result' UNION ALL
  SELECT 1, 'however' UNION ALL
  SELECT 1, 'for example' UNION ALL

  SELECT 2, 'because' UNION ALL
  SELECT 2, 'so' UNION ALL
  SELECT 2, 'therefore' UNION ALL
  SELECT 2, 'however' UNION ALL
  SELECT 2, 'for example' UNION ALL

  SELECT 3, 'for example' UNION ALL
  SELECT 3, 'because' UNION ALL
  SELECT 3, 'therefore' UNION ALL
  SELECT 3, 'however' UNION ALL

  SELECT 4, 'first' UNION ALL
  SELECT 4, 'next' UNION ALL
  SELECT 4, 'finally' UNION ALL
  SELECT 4, 'because' UNION ALL
  SELECT 4, 'so' UNION ALL

  SELECT 5, 'however' UNION ALL
  SELECT 5, 'on the other hand' UNION ALL
  SELECT 5, 'for example' UNION ALL
  SELECT 5, 'because' UNION ALL

  SELECT 6, 'because' UNION ALL
  SELECT 6, 'so' UNION ALL
  SELECT 6, 'therefore' UNION ALL
  SELECT 6, 'for example' UNION ALL

  SELECT 7, 'however' UNION ALL
  SELECT 7, 'although' UNION ALL
  SELECT 7, 'on the other hand' UNION ALL
  SELECT 7, 'therefore' UNION ALL
  SELECT 7, 'for example'
) x ON x.day_no=d.day_no;


/* =========================================================
   (옵션) 예문/동의어/연어까지 “전 단어”로 확장하는 방법
   - 지금은 구조/속도 우선이라 핵심 파생어만 샘플로 넣었음.
   - 원하시면 Day1~Day7의 모든 단어에 대해
     word_synonyms / word_collocations / example_sentences INSERT를
     동일 패턴으로 한 번에 생성해서 드릴게요.
   ========================================================= */