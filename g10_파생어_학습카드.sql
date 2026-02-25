
   ✅ 파생어를 “학습 카드(=words)”로 승격시키는 확장 설계 (MySQL 8+)
   목표:
   1) word_family에 있는 derived_word를 words 테이블에 자동 등록(=승격)
   2) root(기본어휘) ↔ derived(파생어휘) 관계를 “정규화” (word_family_edges)
   3) 파생어에도 definition / collocation / example을 붙일 수 있게 함
   4) 우선 MVP용: 파생어 정의는 자동 생성용 자리표시(placeholder)로 넣고,
      이후 사람이 다듬거나 AI 파이프라인으로 채우는 구조
   ========================================================= */

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS word_family_edges;

SET FOREIGN_KEY_CHECKS=1;

/* ---------------------------------------------------------
   1) words 테이블을 “단어 카드”로 확장하기 위한 컬럼 추가(선택)
   - 기존 words는 headword+pos unique가 있으므로 그대로 사용 가능
   - 아래 컬럼은 선택이지만, 파생어 카드 운영에 매우 유용
   --------------------------------------------------------- */
ALTER TABLE words
  ADD COLUMN IF NOT EXISTS lemma VARCHAR(64) NULL,
  ADD COLUMN IF NOT EXISTS is_derived TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS notes VARCHAR(255) NULL;

/* ---------------------------------------------------------
   2) root ↔ derived 관계를 “word_id ↔ word_id”로 연결하는 edges 테이블
   - derived_word를 문자열로만 갖고 있으면 파생어에 예문/동의어를 붙이기 어려움
   - edges는 단어ID로 연결하므로 파생어도 완전한 학습 카드가 됨
   --------------------------------------------------------- */
CREATE TABLE word_family_edges (
  edge_id       INT AUTO_INCREMENT PRIMARY KEY,
  root_word_id  INT NOT NULL,
  derived_word_id INT NOT NULL,
  relation_type VARCHAR(32) NOT NULL DEFAULT 'derivation',  -- derivation / inflection / phrase 등
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_edge (root_word_id, derived_word_id, relation_type),
  CONSTRAINT fk_edge_root FOREIGN KEY (root_word_id) REFERENCES words(word_id) ON DELETE CASCADE,
  CONSTRAINT fk_edge_derived FOREIGN KEY (derived_word_id) REFERENCES words(word_id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* ---------------------------------------------------------
   3) “파생어 승격” 단계 A: word_family의 derived_word를 words에 INSERT
   - derived_pos 값이 여러 형태(n/adj/v phr 등)라서 그대로 pos에 저장
   - definition_simple은 MVP용 placeholder로 넣고 나중에 채움
   - 이미 존재하면(UNIQUE headword+pos) 무시
   --------------------------------------------------------- */
INSERT IGNORE INTO words (headword, pos, cefr, definition_simple, is_derived, notes)
SELECT
  wf.derived_word AS headword,
  COALESCE(wf.derived_pos, 'unknown') AS pos,
  wf.derived_cefr AS cefr,
  CONCAT('[AUTO] Derived form of: ', w.headword) AS definition_simple,
  1 AS is_derived,
  CONCAT('root=', w.headword, '(', w.pos, ')') AS notes
FROM word_family wf
JOIN words w ON w.word_id = wf.word_id
WHERE wf.derived_word IS NOT NULL AND wf.derived_word <> '';

/* ---------------------------------------------------------
   4) “파생어 승격” 단계 B: edges(관계) 생성
   - root_word_id: words의 root
   - derived_word_id: 방금 승격된 words 레코드
   - relation_type: 기본 derivation
   --------------------------------------------------------- */
INSERT IGNORE INTO word_family_edges (root_word_id, derived_word_id, relation_type)
SELECT
  root.word_id AS root_word_id,
  derived.word_id AS derived_word_id,
  'derivation' AS relation_type
FROM word_family wf
JOIN words root ON root.word_id = wf.word_id
JOIN words derived
  ON derived.headword = wf.derived_word
 AND derived.pos = COALESCE(wf.derived_pos, 'unknown');

/* ---------------------------------------------------------
   5) 파생어를 “학습 카드로 운영”하기 위한 추천: 파생어 예문 자동 생성(placeholder)
   - 예문은 나중에 대체/수정 권장
   - 이미 예문이 있는 파생어는 제외하도록 설계
   --------------------------------------------------------- */

-- (1) 파생어 reading 예문 placeholder
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT d.word_id, 'reading' AS ex_type,
       CONCAT('[AUTO] This sentence uses "', d.headword, '" in context.') AS sentence
FROM words d
LEFT JOIN example_sentences ex
  ON ex.word_id = d.word_id AND ex.ex_type='reading'
WHERE d.is_derived=1
  AND ex.ex_id IS NULL;

-- (2) 파생어 speaking 예문 placeholder
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT d.word_id, 'speaking' AS ex_type,
       CONCAT('[AUTO] I used "', d.headword, '" when I explained my opinion.') AS sentence
FROM words d
LEFT JOIN example_sentences ex
  ON ex.word_id = d.word_id AND ex.ex_type='speaking'
WHERE d.is_derived=1
  AND ex.ex_id IS NULL;

/* ---------------------------------------------------------
   6) 파생어 Collocation placeholder(선택)
   - 실제로는 파생어별 빈출 연어를 별도 큐레이션 추천
   --------------------------------------------------------- */
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT d.word_id,
       CONCAT(d.headword, ' + (common pattern)') AS collocation,
       'low' AS freq_band
FROM words d
LEFT JOIN word_collocations wc ON wc.word_id=d.word_id
WHERE d.is_derived=1
  AND wc.col_id IS NULL;

/* =========================================================
   ✅ 운영 팁(중요)
   1) 파생어 정의를 제대로 운영하려면:
      - word_definitions 테이블(다의어/의미번호) 별도 분리 추천
   2) 지금은 MVP용으로 definition_simple/예문 placeholder로 채웠고
      이후 사람이 다듬거나 AI로 “정의/예문/연어”를 채우면 됨
   ========================================================= */


/* =========================================================
   ✅ 검증 쿼리
   ========================================================= */

-- A) 특정 root 단어의 파생어 카드 목록 보기
-- 예: effect(n)의 파생어
SELECT
  r.headword AS root, r.pos AS root_pos,
  d.headword AS derived, d.pos AS derived_pos, d.cefr AS derived_cefr,
  d.definition_simple
FROM word_family_edges e
JOIN words r ON r.word_id=e.root_word_id
JOIN words d ON d.word_id=e.derived_word_id
WHERE r.headword='effect' AND r.pos='n'
ORDER BY d.headword;

-- B) “파생어 카드”에 예문이 붙었는지 확인
SELECT
  w.headword, w.pos,
  SUM(ex.ex_type='reading') AS has_reading,
  SUM(ex.ex_type='speaking') AS has_speaking
FROM words w
LEFT JOIN example_sentences ex ON ex.word_id=w.word_id
WHERE w.is_derived=1
GROUP BY w.word_id
ORDER BY w.headword
LIMIT 50;

-- C) 파생어가 day_words에 직접 들어가도 되는 구조(선택)
-- 지금은 root 단어 중심 학습이므로 day_words는 유지.
-- 필요 시 “파생어 미션용 day_derived_words” 같은 테이블을 추가하는 것도 가능.