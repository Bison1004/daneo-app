/* =========================================================
   EFL VOCAB APP - schema.sql (HS1 Week1 MVP)
   - MySQL 8.0+
   - Includes: tables, Week1 data, derived missions, views
   ========================================================= */

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;

DROP VIEW IF EXISTS v_day_learning_set;
DROP VIEW IF EXISTS v_word_learning_card;
DROP VIEW IF EXISTS v_root_to_derived_set;

DROP TABLE IF EXISTS day_derived_missions;
DROP TABLE IF EXISTS day_word_set_items;
DROP TABLE IF EXISTS day_word_sets;

DROP TABLE IF EXISTS day_checklist_connectors;
DROP TABLE IF EXISTS day_checklist_collocations;
DROP TABLE IF EXISTS day_checklists;

DROP TABLE IF EXISTS speaking_tasks;

DROP TABLE IF EXISTS day_patterns;
DROP TABLE IF EXISTS patterns;

DROP TABLE IF EXISTS example_sentences;
DROP TABLE IF EXISTS word_collocations;
DROP TABLE IF EXISTS word_synonyms;

DROP TABLE IF EXISTS word_family_edges;
DROP TABLE IF EXISTS day_words;
DROP TABLE IF EXISTS words;
DROP TABLE IF EXISTS days;

SET FOREIGN_KEY_CHECKS=1;

/* =========================================================
   1) Core tables
   ========================================================= */

CREATE TABLE days (
  day_id        INT AUTO_INCREMENT PRIMARY KEY,
  grade         VARCHAR(32) NOT NULL,
  week_no       INT NOT NULL,
  day_no        INT NOT NULL,
  theme         VARCHAR(128) NOT NULL,
  focus         VARCHAR(128) NOT NULL,
  target_cefr   VARCHAR(16),
  target_actfl  VARCHAR(32),
  lexile_band   VARCHAR(32),
  UNIQUE KEY uq_day (grade, week_no, day_no)
) ENGINE=InnoDB;

CREATE TABLE words (
  word_id            INT AUTO_INCREMENT PRIMARY KEY,
  headword           VARCHAR(64) NOT NULL,
  pos                VARCHAR(32) NOT NULL,
  cefr               VARCHAR(16),
  definition_simple  VARCHAR(255) NOT NULL,
  is_derived         TINYINT(1) NOT NULL DEFAULT 0,
  notes              VARCHAR(255),
  UNIQUE KEY uq_headword_pos (headword, pos)
) ENGINE=InnoDB;

CREATE TABLE day_words (
  day_id  INT NOT NULL,
  word_id INT NOT NULL,
  sort_no INT NOT NULL,
  PRIMARY KEY (day_id, word_id),
  UNIQUE KEY uq_day_sort (day_id, sort_no),
  CONSTRAINT fk_dw_day  FOREIGN KEY (day_id)  REFERENCES days(day_id)  ON DELETE CASCADE,
  CONSTRAINT fk_dw_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* root ↔ derived 관계 */
CREATE TABLE word_family_edges (
  edge_id         INT AUTO_INCREMENT PRIMARY KEY,
  root_word_id    INT NOT NULL,
  derived_word_id INT NOT NULL,
  relation_type   VARCHAR(32) NOT NULL DEFAULT 'derivation',
  UNIQUE KEY uq_edge (root_word_id, derived_word_id, relation_type),
  CONSTRAINT fk_edge_root FOREIGN KEY (root_word_id) REFERENCES words(word_id) ON DELETE CASCADE,
  CONSTRAINT fk_edge_derived FOREIGN KEY (derived_word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE word_synonyms (
  syn_id        INT AUTO_INCREMENT PRIMARY KEY,
  word_id       INT NOT NULL,
  synonym_word  VARCHAR(64) NOT NULL,
  nuance_level  INT NOT NULL DEFAULT 1,
  UNIQUE KEY uq_syn (word_id, synonym_word),
  CONSTRAINT fk_syn_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE word_collocations (
  col_id      INT AUTO_INCREMENT PRIMARY KEY,
  word_id     INT NOT NULL,
  collocation VARCHAR(128) NOT NULL,
  freq_band   VARCHAR(16) DEFAULT 'high',
  UNIQUE KEY uq_col (word_id, collocation),
  CONSTRAINT fk_col_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE example_sentences (
  ex_id     INT AUTO_INCREMENT PRIMARY KEY,
  word_id   INT NOT NULL,
  ex_type   ENUM('reading','speaking') NOT NULL,
  sentence  VARCHAR(255) NOT NULL,
  CONSTRAINT fk_ex_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* =========================================================
   2) Patterns + speaking + checklist (Week1)
   ========================================================= */

CREATE TABLE patterns (
  pattern_id VARCHAR(16) PRIMARY KEY,
  structure  VARCHAR(128) NOT NULL,
  level_tag  VARCHAR(16) NOT NULL,
  example    VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE day_patterns (
  day_id     INT NOT NULL,
  pattern_id VARCHAR(16) NOT NULL,
  sort_no    INT NOT NULL,
  PRIMARY KEY (day_id, pattern_id),
  UNIQUE KEY uq_dp_sort (day_id, sort_no),
  CONSTRAINT fk_dp_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE,
  CONSTRAINT fk_dp_pat FOREIGN KEY (pattern_id) REFERENCES patterns(pattern_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE speaking_tasks (
  task_id              INT AUTO_INCREMENT PRIMARY KEY,
  day_id               INT NOT NULL UNIQUE,
  prompt               VARCHAR(255) NOT NULL,
  target_words_min     INT NOT NULL,
  recommended_time_sec INT NOT NULL,
  CONSTRAINT fk_task_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE day_checklists (
  checklist_id    INT AUTO_INCREMENT PRIMARY KEY,
  day_id          INT NOT NULL UNIQUE,
  target_hits_min INT NOT NULL,
  target_hits_max INT NOT NULL,
  points_vocab    INT NOT NULL,
  family_bonus_on TINYINT(1) NOT NULL DEFAULT 1,
  points_family   INT NOT NULL,
  min_words       INT NOT NULL,
  min_sentences   INT NOT NULL,
  CONSTRAINT fk_chk_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE day_checklist_collocations (
  checklist_id INT NOT NULL,
  collocation  VARCHAR(128) NOT NULL,
  PRIMARY KEY (checklist_id, collocation),
  CONSTRAINT fk_chkcol FOREIGN KEY (checklist_id) REFERENCES day_checklists(checklist_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE day_checklist_connectors (
  checklist_id INT NOT NULL,
  connector    VARCHAR(32) NOT NULL,
  PRIMARY KEY (checklist_id, connector),
  CONSTRAINT fk_chkcon FOREIGN KEY (checklist_id) REFERENCES day_checklists(checklist_id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* =========================================================
   3) Day learning set (root 10 + derived 3 missions)
   ========================================================= */

CREATE TABLE day_word_sets (
  set_id     INT AUTO_INCREMENT PRIMARY KEY,
  day_id     INT NOT NULL UNIQUE,
  title      VARCHAR(128) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_set_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE day_word_set_items (
  set_item_id  INT AUTO_INCREMENT PRIMARY KEY,
  set_id       INT NOT NULL,
  word_id      INT NOT NULL,
  item_type    ENUM('root','derived') NOT NULL,
  root_word_id INT NULL,
  sort_no      INT NOT NULL,
  UNIQUE KEY uq_set_word (set_id, word_id),
  UNIQUE KEY uq_set_sort (set_id, sort_no),
  CONSTRAINT fk_item_set FOREIGN KEY (set_id) REFERENCES day_word_sets(set_id) ON DELETE CASCADE,
  CONSTRAINT fk_item_word FOREIGN KEY (word_id) REFERENCES words(word_id) ON DELETE CASCADE,
  CONSTRAINT fk_item_root FOREIGN KEY (root_word_id) REFERENCES words(word_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE day_derived_missions (
  mission_id      INT AUTO_INCREMENT PRIMARY KEY,
  day_id          INT NOT NULL,
  derived_word_id INT NOT NULL,
  root_word_id    INT NOT NULL,
  mission_type    ENUM('use_in_speaking','use_in_sentence','collocation_focus') NOT NULL DEFAULT 'use_in_speaking',
  difficulty_tag  VARCHAR(16) DEFAULT 'B1',
  sort_no         INT NOT NULL,
  UNIQUE KEY uq_day_mission_sort (day_id, sort_no),
  UNIQUE KEY uq_day_derived (day_id, derived_word_id),
  CONSTRAINT fk_m_day FOREIGN KEY (day_id) REFERENCES days(day_id) ON DELETE CASCADE,
  CONSTRAINT fk_m_derived FOREIGN KEY (derived_word_id) REFERENCES words(word_id) ON DELETE CASCADE,
  CONSTRAINT fk_m_root FOREIGN KEY (root_word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* =========================================================
   4) INSERT: Days (HS1 Week1 Day1~Day7)
   ========================================================= */

INSERT INTO days (grade, week_no, day_no, theme, focus, target_cefr, target_actfl, lexile_band) VALUES
('HighSchool_1', 1, 1, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'cause-effect basics', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 2, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'problem-solution + prevention', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 3, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'evidence + claims (Suneung logic)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 4, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'process & steps (speaking clarity)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 5, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'comparison (Suneung frequent)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 6, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'opinion + reason + example (speaking core)', 'A2+~B1', 'Intermediate Mid', '950~1100L'),
('HighSchool_1', 1, 7, 'Cause-Effect & Problem-Solution (Suneung + Speaking)', 'mini debate (counterargument)', 'A2+~B1', 'Intermediate Mid', '950~1100L');

/* =========================================================
   5) INSERT: Patterns (P01~P14) + Day patterns
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

/* speaking tasks */
INSERT INTO speaking_tasks (day_id, prompt, target_words_min, recommended_time_sec)
SELECT d.day_id, t.prompt, t.min_words, t.sec
FROM days d
JOIN (
  SELECT 1 day_no, 'What causes students to feel stressed at school? Explain one main cause and one effect. Give one solution.' prompt, 5 min_words, 60 sec UNION ALL
  SELECT 2, 'Choose one school issue (sleep, phone use, or homework). Describe the problem, explain one risk, and suggest one strategy to prevent it.', 5, 60 UNION ALL
  SELECT 3, 'Make one claim about studying (sleep, review, or phone use). Give evidence (a fact, research, or personal example), and conclude your opinion.', 5, 70 UNION ALL
  SELECT 4, 'Explain your study process in three steps. Include one method you use to maintain consistency and reach your goal.', 5, 60 UNION ALL
  SELECT 5, 'Compare online learning and offline learning. Mention one advantage and one disadvantage, and say which you prefer and why.', 5, 70 UNION ALL
  SELECT 6, 'In your opinion, what is the best way to improve English speaking? Give one reason and one example, and recommend a habit.', 5, 75 UNION ALL
  SELECT 7, 'Topic: Smartphones in school. Present one argument for, one argument against, and your final opinion. Use however/although at least once.', 5, 80
) t ON t.day_no=d.day_no
WHERE d.grade='HighSchool_1' AND d.week_no=1;

/* checklist (간단 버전) */
INSERT INTO day_checklists (day_id, target_hits_min, target_hits_max, points_vocab, family_bonus_on, points_family, min_words, min_sentences)
SELECT d.day_id, c.minHit, 10, 25, 1, 10, c.minW, c.minS
FROM days d
JOIN (
  SELECT 1 day_no, 5 minHit, 45 minW, 3 minS UNION ALL
  SELECT 2, 5, 45, 3 UNION ALL
  SELECT 3, 5, 55, 4 UNION ALL
  SELECT 4, 5, 45, 3 UNION ALL
  SELECT 5, 5, 55, 4 UNION ALL
  SELECT 6, 5, 60, 4 UNION ALL
  SELECT 7, 5, 65, 5
) c ON c.day_no=d.day_no
WHERE d.grade='HighSchool_1' AND d.week_no=1;

/* =========================================================
   6) INSERT: Words (root + derived used in Week1)
   ========================================================= */

-- Root words (Day1~Day7)
INSERT INTO words (headword, pos, cefr, definition_simple, is_derived) VALUES
('cause','v/n','A2','to make something happen; the reason something happens',0),
('effect','n','A2','a result or change caused by something',0),
('affect','v','B1','to change or influence something',0),
('result','n/v','A2','something that happens because of something else',0),
('factor','n','B1','one important part that influences a situation',0),
('increase','v/n','A2','to become larger or greater',0),
('reduce','v','B1','to make something smaller or less',0),
('require','v','B1','to need something; to make something necessary',0),
('solution','n','B1','a way to solve a problem',0),
('impact','n/v','B1','a strong effect or influence; to strongly affect',0),

('issue','n','B1','an important problem or topic',0),
('challenge','n','B1','something difficult that tests you',0),
('prevent','v','B1','to stop something from happening',0),
('avoid','v','A2','to stay away from; not do something',0),
('manage','v','B1','to control or handle something',0),
('support','v/n','A2+','to help; help given',0),
('suggest','v','B1','to recommend an idea',0),
('strategy','n','B1','a plan to achieve a goal',0),
('risk','n','B1','the chance of something bad happening',0),
('benefit','n/v','B1','a good result; to help',0),

('evidence','n','B1','facts or signs that show something is true',0),
('claim','n/v','B1','to say something is true; a statement',0),
('argue','v','B1','to give reasons for your opinion',0),
('conclude','v','B1','to decide after thinking; to end',0),
('indicate','v','B1','to show or suggest',0),
('research','n/v','B1','careful study to discover facts',0),
('data','n','B1','information, often numbers, used for analysis',0),
('trend','n','B1','a general direction of change',0),

('process','n','B1','a series of actions to achieve a result',0),
('method','n','B1','a way of doing something',0),
('step','n','A2','one action in a process',0),
('practice','n/v','A2','to do something repeatedly to improve',0),
('improve','v','A2','to make something better',0),
('maintain','v','B1','to keep something at the same level',0),
('focus','v/n','A2+','to pay attention to one thing',0),
('review','v/n','B1','to look at something again to remember it',0),
('consistency','n','B1','doing something in the same way regularly',0),
('goal','n','A2','something you want to achieve',0),

('compare','v','A2+','to look at similarities and differences',0),
('contrast','v/n','B1','to show differences clearly',0),
('similar','adj','A2','almost the same',0),
('different','adj','A1','not the same',0),
('advantage','n','B1','a good point or benefit',0),
('disadvantage','n','B1','a bad point',0),
('prefer','v','A2','to like one thing more than another',0),
('option','n','A2','a choice',0),
('balance','n/v','B1','a healthy mix; to keep things equal',0),
('efficient','adj','B1','working well without wasting time or energy',0),

('opinion','n','A2+','what you think or believe',0),
('reason','n','A2','a cause or explanation',0),
('example','n','A2','something that shows what you mean',0),
('explain','v','A2+','to make something clear',0),
('recommend','v','B1','to suggest something as good',0),
('decide','v','A2','to choose after thinking',0),
('pressure','n','B1','stress or force from expectations',0),
('motivate','v','B1','to make someone want to do something',0),
('confidence','n','B1','belief that you can do something well',0),
('habit','n','A2+','something you do regularly',0),

('agree','v','A2','to have the same opinion',0),
('disagree','v','A2+','to have a different opinion',0),
('however','adv','B1','used to show a contrast',0),
('although','conj','B1','used to introduce a contrast',0),
('consider','v','B1','to think carefully about',0),
('perspective','n','B1+','a way of thinking about something',0),
('limit','v/n','B1','to control the size or amount; a maximum amount',0),
('necessary','adj','A2+','needed; important',0),
('effective','adj','B1','working well and producing results',0);

-- Derived words (used as missions / family)
INSERT INTO words (headword, pos, cefr, definition_simple, is_derived, notes) VALUES
('causal','adj','B1','related to cause and effect',1,'from cause'),
('causation','n','B2','the process of causing something; cause-and-effect relationship',1,'from cause'),
('cause-and-effect','n','B1','a cause-and-effect relationship (as a concept)',1,'from cause'),


('effectively','adv','B1','in a way that produces good results',1,'from effect'),
('effectiveness','n','B2','how well something works; the ability to produce results',1,'from effect'),
('ineffective','adj','B2','not producing results; not effective',1,'from effect'),

('increasing','adj','B1','becoming greater; growing',1,'from increase'),
('increasingly','adv','B1','more and more; to an increasing degree',1,'from increase'),

('reduction','n','B1','a decrease in size, amount, or number',1,'from reduce'),

('required','adj','A2+','needed or demanded; must be done',1,'from require'),
('requirement','n','B1','something you need; a rule or condition that must be met',1,'from require'),

('solve','v','B1','to find the answer to a problem; to deal with a difficulty',1,'from solution'),
('solvable','adj','B2','able to be solved',1,'from solution'),
('unsolved','adj','B2','not yet solved',1,'from solution'),

('prevention','n','B1','stopping something bad from happening',1,'from prevent'),
('preventive','adj','B2','intended to prevent problems or disease',1,'from prevent'),

('avoidable','adj','B1','able to be avoided or prevented',1,'from avoid'),
('avoidance','n','B2','a way of avoiding something; the act of avoiding',1,'from avoid'),

('supportive','adj','B1','giving help and encouragement',1,'from support'),
('suggestion','n','B1','an idea or piece of advice about what to do',1,'from suggest'),

('strategic','adj','B2','related to planning for a goal in a smart way',1,'from strategy'),
('strategically','adv','B2','in a strategic way',1,'from strategy'),
('strategist','n','B2','a person who makes plans for success',1,'from strategy'),

('risky','adj','B1','likely to cause danger or loss',1,'from risk'),

('beneficial','adj','B1','helpful; producing good results',1,'from benefit'),
('beneficiary','n','B2','a person who receives help or benefits',1,'from benefit'),

('evident','adj','B1','easy to see or understand; clear',1,'from evidence'),
('evidently','adv','B2','clearly; obviously',1,'from evidence'),

('argument','n','B1','a reasoned discussion; reasons supporting a view',1,'from argue'),
('conclusion','n','B1','a final decision or result of thinking; the ending part',1,'from conclude'),
('indication','n','B1','a sign that something exists or is true',1,'from indicate'),

('researcher','n','B1','a person who does research',1,'from research'),
('database','n','B1','a collection of organized data, often in a computer system',1,'from data'),
('research-based','adj','B2','based on research and evidence',1,'from research'),
('data-driven','adj','B2','based on data; using data to make decisions',1,'from data'),

('methodical','adj','B2','done in a careful and organized way',1,'from method'),
('practical','adj','B1','useful in real situations; not only theoretical',1,'from practice'),
('improvement','n','B1','a change that makes something better',1,'from improve'),
('maintenance','n','B2','work needed to keep something in good condition',1,'from maintain'),
('focused','adj','B1','paying close attention; not distracted',1,'from focus'),
('revision','n','B1','the act of revising; a changed version',1,'from review'),
('consistent','adj','B1','regular and steady; not changing often',1,'from consistency'),
('consistently','adv','B1','in a steady and regular way',1,'from consistency'),
('goal-setting','n','B1','planning how to reach goals',1,'from goal'),

('comparison','n','B1','the act of comparing; a look at similarities and differences',1,'from compare'),
('comparative','adj','B1','used for comparing; showing similarities and differences',1,'from compare'),
('similarity','n','B1','the state of being similar',1,'from similar'),
('difference','n','A2+','a difference; the state of not being the same',1,'from different'),
('differ','v','B1','to be different (often with “from”)',1,'from different'),
('preference','n','B1','what someone likes or chooses more than something else',1,'from prefer'),
('optional','adj','B1','not required; you can choose it',1,'from option'),
('balanced','adj','B1','in a healthy or equal state; not extreme',1,'from balance'),
('efficiency','n','B1','how well something uses time/energy; being efficient',1,'from efficient'),

('recommendation','n','B1','a suggestion about what should be done',1,'from recommend'),
('decision','n','B1','a choice you make after thinking',1,'from decide'),
('motivation','n','B1','the reason or desire to do something',1,'from motivate'),
('confident','adj','B1','feeling sure that you can do something well',1,'from confidence'),
('confidently','adv','B1','in a confident way',1,'from confidence'),

('agreement','n','B1','a situation where people have the same opinion',1,'from agree'),
('disagreement','n','B1','a situation where people have different opinions',1,'from disagree'),
('limitation','n','B2','a rule or condition that restricts something; a weakness',1,'from limit'),
('necessity','n','B2','something that is needed; something necessary',1,'from necessary'),
('unnecessary','adj','B1','not necessary',1,'from necessary'),
('imbalance','n','B2','the state of not having balance',1,'from balance'),
('unbalanced','adj','B2','not balanced; not in a healthy/equal state',1,'from balance')
;

/* =========================================================
   7) Map day_words (Week1: root 10 each day)
   ========================================================= */

INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, x.sort_no
FROM days d
JOIN (
  SELECT 1 AS day_no, 1 AS sort_no, 'cause' AS hw, 'v/n' AS pos UNION ALL
  SELECT 1, 2, 'effect', 'n' UNION ALL
  SELECT 1, 3, 'affect', 'v' UNION ALL
  SELECT 1, 4, 'result', 'n/v' UNION ALL
  SELECT 1, 5, 'factor', 'n' UNION ALL
  SELECT 1, 6, 'increase', 'v/n' UNION ALL
  SELECT 1, 7, 'reduce', 'v' UNION ALL
  SELECT 1, 8, 'require', 'v' UNION ALL
  SELECT 1, 9, 'solution', 'n' UNION ALL
  SELECT 1,10, 'impact', 'n/v' UNION ALL

  SELECT 2, 1, 'issue', 'n' UNION ALL
  SELECT 2, 2, 'challenge', 'n' UNION ALL
  SELECT 2, 3, 'prevent', 'v' UNION ALL
  SELECT 2, 4, 'avoid', 'v' UNION ALL
  SELECT 2, 5, 'manage', 'v' UNION ALL
  SELECT 2, 6, 'support', 'v/n' UNION ALL
  SELECT 2, 7, 'suggest', 'v' UNION ALL
  SELECT 2, 8, 'strategy', 'n' UNION ALL
  SELECT 2, 9, 'risk', 'n' UNION ALL
  SELECT 2,10, 'benefit', 'n/v' UNION ALL

  SELECT 3, 1, 'evidence', 'n' UNION ALL
  SELECT 3, 2, 'claim', 'n/v' UNION ALL
  SELECT 3, 3, 'argue', 'v' UNION ALL
  SELECT 3, 4, 'support', 'v/n' UNION ALL
  SELECT 3, 5, 'conclude', 'v' UNION ALL
  SELECT 3, 6, 'indicate', 'v' UNION ALL
  SELECT 3, 7, 'research', 'n/v' UNION ALL
  SELECT 3, 8, 'data', 'n' UNION ALL
  SELECT 3, 9, 'trend', 'n' UNION ALL
  SELECT 3,10, 'impact', 'n/v' UNION ALL

  SELECT 4, 1, 'process', 'n' UNION ALL
  SELECT 4, 2, 'method', 'n' UNION ALL
  SELECT 4, 3, 'step', 'n' UNION ALL
  SELECT 4, 4, 'practice', 'n/v' UNION ALL
  SELECT 4, 5, 'improve', 'v' UNION ALL
  SELECT 4, 6, 'maintain', 'v' UNION ALL
  SELECT 4, 7, 'focus', 'v/n' UNION ALL
  SELECT 4, 8, 'review', 'v/n' UNION ALL
  SELECT 4, 9, 'consistency', 'n' UNION ALL
  SELECT 4,10, 'goal', 'n' UNION ALL

  SELECT 5, 1, 'compare', 'v' UNION ALL
  SELECT 5, 2, 'contrast', 'v/n' UNION ALL
  SELECT 5, 3, 'similar', 'adj' UNION ALL
  SELECT 5, 4, 'different', 'adj' UNION ALL
  SELECT 5, 5, 'advantage', 'n' UNION ALL
  SELECT 5, 6, 'disadvantage', 'n' UNION ALL
  SELECT 5, 7, 'prefer', 'v' UNION ALL
  SELECT 5, 8, 'option', 'n' UNION ALL
  SELECT 5, 9, 'balance', 'n/v' UNION ALL
  SELECT 5,10, 'efficient', 'adj' UNION ALL

  SELECT 6, 1, 'opinion', 'n' UNION ALL
  SELECT 6, 2, 'reason', 'n' UNION ALL
  SELECT 6, 3, 'example', 'n' UNION ALL
  SELECT 6, 4, 'explain', 'v' UNION ALL
  SELECT 6, 5, 'recommend', 'v' UNION ALL
  SELECT 6, 6, 'decide', 'v' UNION ALL
  SELECT 6, 7, 'pressure', 'n' UNION ALL
  SELECT 6, 8, 'motivate', 'v' UNION ALL
  SELECT 6, 9, 'confidence', 'n' UNION ALL
  SELECT 6,10, 'habit', 'n' UNION ALL

  SELECT 7, 1, 'argue', 'v' UNION ALL
  SELECT 7, 2, 'agree', 'v' UNION ALL
  SELECT 7, 3, 'disagree', 'v' UNION ALL
  SELECT 7, 4, 'however', 'adv' UNION ALL
  SELECT 7, 5, 'although', 'conj' UNION ALL
  SELECT 7, 6, 'consider', 'v' UNION ALL
  SELECT 7, 7, 'perspective', 'n' UNION ALL
  SELECT 7, 8, 'limit', 'v/n' UNION ALL
  SELECT 7, 9, 'necessary', 'adj' UNION ALL
  SELECT 7,10, 'effective', 'adj'
) x ON x.day_no = d.day_no
JOIN words w ON w.headword = x.hw AND w.pos = x.pos
WHERE d.grade='HighSchool_1' AND d.week_no=1;