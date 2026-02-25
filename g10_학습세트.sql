/* =========================================================
   ✅ HS1 Week1 파생어 “학습세트” 완성 SQL
   목표(파생어 카드 기준):
   1) 파생어(words.is_derived=1)에 동의어(word_synonyms) 정교화
   2) 이미 완료된 항목: 정의(words), 예문(example_sentences), 연어(word_collocations)
   3) “학습세트 조회”를 위한 VIEW 2개 제공
   ========================================================= */

START TRANSACTION;

/* ---------------------------------------------------------
   0) (선택) 파생어 동의어 중복 방지용 UNIQUE 권장
   - 이미 운영 중이면 스킵해도 됨
--------------------------------------------------------- */
-- ALTER TABLE word_synonyms ADD UNIQUE KEY uq_syn (word_id, synonym_word);

/* ---------------------------------------------------------
   1) 파생어 동의어 정교화 INSERT
   - root 단어 동의어와 “겹치더라도” 파생어 카드에서는 별도 필요
--------------------------------------------------------- */
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  /* ===== cause-family ===== */
  SELECT 'causal' hw,'adj' pos,'cause-and-effect' syn,1 lv UNION ALL
  SELECT 'causal','adj','related' ,2 UNION ALL
  SELECT 'causal','adj','direct' ,2 UNION ALL

  SELECT 'causation' hw,'n' pos,'cause' syn,1 lv UNION ALL
  SELECT 'causation','n','cause-and-effect' ,1 UNION ALL
  SELECT 'causation','n','reason' ,2 UNION ALL

  SELECT 'cause-and-effect' hw,'n' pos,'causation' syn,1 lv UNION ALL
  SELECT 'cause-and-effect','n','relationship' ,2 UNION ALL
  SELECT 'cause-and-effect','n','connection' ,2 UNION ALL

  /* ===== effect-family ===== */
  SELECT 'effective' hw,'adj' pos,'successful' syn,1 lv UNION ALL
  SELECT 'effective','adj','useful' ,1 UNION ALL
  SELECT 'effective','adj','efficient' ,2 UNION ALL

  SELECT 'effectively' hw,'adv' pos,'successfully' syn,1 lv UNION ALL
  SELECT 'effectively','adv','well' ,1 UNION ALL
  SELECT 'effectively','adv','efficiently' ,2 UNION ALL

  SELECT 'effectiveness' hw,'n' pos,'success' syn,2 lv UNION ALL
  SELECT 'effectiveness','n','power' ,2 UNION ALL
  SELECT 'effectiveness','n','impact' ,2 UNION ALL

  SELECT 'ineffective' hw,'adj' pos,'useless' syn,1 lv UNION ALL
  SELECT 'ineffective','adj','unsuccessful' ,2 UNION ALL
  SELECT 'ineffective','adj','weak' ,2 UNION ALL

  /* ===== increase/reduce/require/solution ===== */
  SELECT 'increasing' hw,'adj' pos,'growing' syn,1 lv UNION ALL
  SELECT 'increasing','adj','rising' ,1 UNION ALL
  SELECT 'increasing','adj','expanding' ,2 UNION ALL

  SELECT 'increasingly' hw,'adv' pos,'more and more' syn,1 lv UNION ALL
  SELECT 'increasingly','adv','gradually' ,2 UNION ALL
  SELECT 'increasingly','adv','progressively' ,3 UNION ALL

  SELECT 'reduction' hw,'n' pos,'decrease' syn,1 lv UNION ALL
  SELECT 'reduction','n','cut' ,1 UNION ALL
  SELECT 'reduction','n','drop' ,2 UNION ALL

  SELECT 'required' hw,'adj' pos,'necessary' syn,1 lv UNION ALL
  SELECT 'required','adj','needed' ,1 UNION ALL
  SELECT 'required','adj','mandatory' ,2 UNION ALL

  SELECT 'requirement' hw,'n' pos,'condition' syn,2 lv UNION ALL
  SELECT 'requirement','n','need' ,1 UNION ALL
  SELECT 'requirement','n','rule' ,2 UNION ALL

  SELECT 'solve' hw,'v' pos,'fix' syn,1 lv UNION ALL
  SELECT 'solve','v','deal with' ,2 UNION ALL
  SELECT 'solve','v','figure out' ,2 UNION ALL

  SELECT 'solvable' hw,'adj' pos,'fixable' syn,1 lv UNION ALL
  SELECT 'solvable','adj','manageable' ,2 UNION ALL
  SELECT 'solvable','adj','possible' ,2 UNION ALL

  SELECT 'unsolved' hw,'adj' pos,'unanswered' syn,2 lv UNION ALL
  SELECT 'unsolved','adj','unresolved' ,2 UNION ALL
  SELECT 'unsolved','adj','mysterious' ,3 UNION ALL

  /* ===== prevention/avoid/support/strategy/risk/benefit ===== */
  SELECT 'prevention' hw,'n' pos,'avoidance' syn,2 lv UNION ALL
  SELECT 'prevention','n','protection' ,2 UNION ALL
  SELECT 'prevention','n','control' ,3 UNION ALL

  SELECT 'preventive' hw,'adj' pos,'protective' syn,2 lv UNION ALL
  SELECT 'preventive','adj','preparatory' ,3 UNION ALL
  SELECT 'preventive','adj','proactive' ,3 UNION ALL

  SELECT 'avoidable' hw,'adj' pos,'preventable' syn,1 lv UNION ALL
  SELECT 'avoidable','adj','unnecessary' ,2 UNION ALL
  SELECT 'avoidable','adj','not required' ,2 UNION ALL

  SELECT 'avoidance' hw,'n' pos,'prevention' syn,2 lv UNION ALL
  SELECT 'avoidance','n','escape' ,2 UNION ALL
  SELECT 'avoidance','n','refusal' ,3 UNION ALL

  SELECT 'supportive' hw,'adj' pos,'helpful' syn,1 lv UNION ALL
  SELECT 'supportive','adj','encouraging' ,2 UNION ALL
  SELECT 'supportive','adj','caring' ,2 UNION ALL

  SELECT 'suggestion' hw,'n' pos,'advice' syn,1 lv UNION ALL
  SELECT 'suggestion','n','idea' ,1 UNION ALL
  SELECT 'suggestion','n','proposal' ,2 UNION ALL

  SELECT 'strategic' hw,'adj' pos,'planned' syn,1 lv UNION ALL
  SELECT 'strategic','adj','smart' ,1 UNION ALL
  SELECT 'strategic','adj','long-term' ,2 UNION ALL

  SELECT 'strategically' hw,'adv' pos,'wisely' syn,2 lv UNION ALL
  SELECT 'strategically','adv','carefully' ,2 UNION ALL
  SELECT 'strategically','adv','purposefully' ,3 UNION ALL

  SELECT 'strategist' hw,'n' pos,'planner' syn,2 lv UNION ALL
  SELECT 'strategist','n','advisor' ,2 UNION ALL
  SELECT 'strategist','n','expert' ,2 UNION ALL

  SELECT 'risky' hw,'adj' pos,'dangerous' syn,1 lv UNION ALL
  SELECT 'risky','adj','unsafe' ,1 UNION ALL
  SELECT 'risky','adj','uncertain' ,2 UNION ALL

  SELECT 'beneficial' hw,'adj' pos,'helpful' syn,1 lv UNION ALL
  SELECT 'beneficial','adj','useful' ,1 UNION ALL
  SELECT 'beneficial','adj','good for' ,1 UNION ALL

  SELECT 'beneficiary' hw,'n' pos,'receiver' syn,2 lv UNION ALL
  SELECT 'beneficiary','n','recipient' ,3 UNION ALL
  SELECT 'beneficiary','n','winner' ,2 UNION ALL

  /* ===== evidence/reasoning ===== */
  SELECT 'evident' hw,'adj' pos,'clear' syn,1 lv UNION ALL
  SELECT 'evident','adj','obvious' ,1 UNION ALL
  SELECT 'evident','adj','noticeable' ,2 UNION ALL

  SELECT 'evidently' hw,'adv' pos,'clearly' syn,1 lv UNION ALL
  SELECT 'evidently','adv','obviously' ,1 UNION ALL
  SELECT 'evidently','adv','apparently' ,2 UNION ALL

  SELECT 'argument' hw,'n' pos,'reasoning' syn,2 lv UNION ALL
  SELECT 'argument','n','claim' ,2 UNION ALL
  SELECT 'argument','n','debate' ,2 UNION ALL

  SELECT 'conclusion' hw,'n' pos,'ending' syn,1 lv UNION ALL
  SELECT 'conclusion','n','result' ,1 UNION ALL
  SELECT 'conclusion','n','summary' ,2 UNION ALL

  SELECT 'indication' hw,'n' pos,'sign' syn,1 lv UNION ALL
  SELECT 'indication','n','signal' ,2 UNION ALL
  SELECT 'indication','n','evidence' ,2 UNION ALL

  SELECT 'researcher' hw,'n' pos,'scientist' syn,2 lv UNION ALL
  SELECT 'researcher','n','investigator' ,2 UNION ALL
  SELECT 'researcher','n','scholar' ,3 UNION ALL

  SELECT 'database' hw,'n' pos,'data system' syn,2 lv UNION ALL
  SELECT 'database','n','data storage' ,2 UNION ALL
  SELECT 'database','n','data bank' ,3 UNION ALL

  SELECT 'research-based' hw,'adj' pos,'evidence-based' syn,2 lv UNION ALL
  SELECT 'research-based','adj','scientific' ,2 UNION ALL
  SELECT 'research-based','adj','proven' ,2 UNION ALL

  SELECT 'data-driven' hw,'adj' pos,'evidence-based' syn,2 lv UNION ALL
  SELECT 'data-driven','adj','fact-based' ,2 UNION ALL
  SELECT 'data-driven','adj','analytical' ,3 UNION ALL

  /* ===== study process ===== */
  SELECT 'methodical' hw,'adj' pos,'systematic' syn,2 lv UNION ALL
  SELECT 'methodical','adj','organized' ,1 UNION ALL
  SELECT 'methodical','adj','careful' ,1 UNION ALL

  SELECT 'practical' hw,'adj' pos,'useful' syn,1 lv UNION ALL
  SELECT 'practical','adj','realistic' ,2 UNION ALL
  SELECT 'practical','adj','hands-on' ,3 UNION ALL

  SELECT 'improvement' hw,'n' pos,'progress' syn,1 lv UNION ALL
  SELECT 'improvement','n','growth' ,2 UNION ALL
  SELECT 'improvement','n','advance' ,2 UNION ALL

  SELECT 'maintenance' hw,'n' pos,'upkeep' syn,2 lv UNION ALL
  SELECT 'maintenance','n','care' ,1 UNION ALL
  SELECT 'maintenance','n','repair' ,2 UNION ALL

  SELECT 'focused' hw,'adj' pos,'concentrated' syn,2 lv UNION ALL
  SELECT 'focused','adj','attentive' ,2 UNION ALL
  SELECT 'focused','adj','not distracted' ,1 UNION ALL

  SELECT 'revision' hw,'n' pos,'review' syn,1 lv UNION ALL
  SELECT 'revision','n','editing' ,2 UNION ALL
  SELECT 'revision','n','re-check' ,2 UNION ALL

  SELECT 'consistent' hw,'adj' pos,'steady' syn,1 lv UNION ALL
  SELECT 'consistent','adj','regular' ,1 UNION ALL
  SELECT 'consistent','adj','reliable' ,2 UNION ALL

  SELECT 'consistently' hw,'adv' pos,'regularly' syn,1 lv UNION ALL
  SELECT 'consistently','adv','steadily' ,2 UNION ALL
  SELECT 'consistently','adv','repeatedly' ,2 UNION ALL

  SELECT 'goal-setting' hw,'n' pos,'planning' syn,1 lv UNION ALL
  SELECT 'goal-setting','n','targeting' ,2 UNION ALL
  SELECT 'goal-setting','n','goal planning' ,1 UNION ALL

  /* ===== compare & contrast ===== */
  SELECT 'comparison' hw,'n' pos,'contrast' syn,2 lv UNION ALL
  SELECT 'comparison','n','evaluation' ,2 UNION ALL
  SELECT 'comparison','n','matchup' ,3 UNION ALL

  SELECT 'comparative' hw,'adj' pos,'relative' syn,2 lv UNION ALL
  SELECT 'comparative','adj','comparing' ,1 UNION ALL
  SELECT 'comparative','adj','contrastive' ,3 UNION ALL

  SELECT 'similarity' hw,'n' pos,'likeness' syn,2 lv UNION ALL
  SELECT 'similarity','n','resemblance' ,3 UNION ALL
  SELECT 'similarity','n','common point' ,2 UNION ALL

  SELECT 'difference' hw,'n' pos,'distinction' syn,3 lv UNION ALL
  SELECT 'difference','n','gap' ,2 UNION ALL
  SELECT 'difference','n','change' ,2 UNION ALL

  SELECT 'differ' hw,'v' pos,'vary' syn,2 lv UNION ALL
  SELECT 'differ','v','change' ,2 UNION ALL
  SELECT 'differ','v','disagree' ,2 UNION ALL

  SELECT 'preference' hw,'n' pos,'choice' syn,1 lv UNION ALL
  SELECT 'preference','n','favorite' ,2 UNION ALL
  SELECT 'preference','n','liking' ,2 UNION ALL

  SELECT 'optional' hw,'adj' pos,'not required' syn,1 lv UNION ALL
  SELECT 'optional','adj','extra' ,1 UNION ALL
  SELECT 'optional','adj','elective' ,2 UNION ALL

  SELECT 'balanced' hw,'adj' pos,'stable' syn,2 lv UNION ALL
  SELECT 'balanced','adj','healthy' ,1 UNION ALL
  SELECT 'balanced','adj','well-planned' ,2 UNION ALL

  SELECT 'efficiency' hw,'n' pos,'productivity' syn,2 lv UNION ALL
  SELECT 'efficiency','n','effectiveness' ,2 UNION ALL
  SELECT 'efficiency','n','speed' ,2 UNION ALL

  /* ===== speaking core ===== */
  SELECT 'recommendation' hw,'n' pos,'advice' syn,1 lv UNION ALL
  SELECT 'recommendation','n','suggestion' ,1 UNION ALL
  SELECT 'recommendation','n','guidance' ,2 UNION ALL

  SELECT 'decision' hw,'n' pos,'choice' syn,1 lv UNION ALL
  SELECT 'decision','n','judgment' ,2 UNION ALL
  SELECT 'decision','n','resolution' ,2 UNION ALL

  SELECT 'motivation' hw,'n' pos,'drive' syn,2 lv UNION ALL
  SELECT 'motivation','n','desire' ,1 UNION ALL
  SELECT 'motivation','n','encouragement' ,2 UNION ALL

  SELECT 'confident' hw,'adj' pos,'sure' syn,1 lv UNION ALL
  SELECT 'confident','adj','self-assured' ,3 UNION ALL
  SELECT 'confident','adj','comfortable' ,2 UNION ALL

  SELECT 'confidently' hw,'adv' pos,'surely' syn,2 lv UNION ALL
  SELECT 'confidently','adv','without hesitation' ,3 UNION ALL
  SELECT 'confidently','adv','clearly' ,2 UNION ALL

  /* ===== debate core ===== */
  SELECT 'agreement' hw,'n' pos,'deal' syn,2 lv UNION ALL
  SELECT 'agreement','n','understanding' ,2 UNION ALL
  SELECT 'agreement','n','consensus' ,3 UNION ALL

  SELECT 'disagreement' hw,'n' pos,'conflict' syn,2 lv UNION ALL
  SELECT 'disagreement','n','difference of opinion' ,2 UNION ALL
  SELECT 'disagreement','n','argument' ,2 UNION ALL

  SELECT 'limitation' hw,'n' pos,'weakness' syn,2 lv UNION ALL
  SELECT 'limitation','n','restriction' ,2 UNION ALL
  SELECT 'limitation','n','drawback' ,2 UNION ALL

  SELECT 'necessity' hw,'n' pos,'need' syn,1 lv UNION ALL
  SELECT 'necessity','n','requirement' ,2 UNION ALL
  SELECT 'necessity','n','must' ,2 UNION ALL

  SELECT 'unnecessary' hw,'adj' pos,'not needed' syn,1 lv UNION ALL
  SELECT 'unnecessary','adj','needless' ,2 UNION ALL
  SELECT 'unnecessary','adj','extra' ,2 UNION ALL

  SELECT 'imbalance' hw,'n' pos,'unevenness' syn,3 lv UNION ALL
  SELECT 'imbalance','n','lack of balance' ,2 UNION ALL
  SELECT 'imbalance','n','unfairness' ,3 UNION ALL

  SELECT 'unbalanced' hw,'adj' pos,'uneven' syn,2 lv UNION ALL
  SELECT 'unbalanced','adj','not healthy' ,2 UNION ALL
  SELECT 'unbalanced','adj','unstable' ,2 UNION ALL
) x ON x.hw=w.headword AND x.pos=w.pos
WHERE w.is_derived=1
-- 중복 방지
AND NOT EXISTS (
  SELECT 1 FROM word_synonyms s
  WHERE s.word_id=w.word_id AND s.synonym_word=x.syn
);

COMMIT;


/* =========================================================
   2) ✅ 학습세트 조회용 VIEW
   - (A) 파생어 카드 상세(정의/연어/예문/동의어) 1개 단어 기준
   - (B) root 단어의 파생어 세트(관계 포함) 조회
   ========================================================= */

DROP VIEW IF EXISTS v_word_learning_card;
CREATE VIEW v_word_learning_card AS
SELECT
  w.word_id,
  w.headword,
  w.pos,
  w.cefr,
  w.is_derived,
  w.definition_simple,

  -- 동의어(최대 10개)
  (SELECT GROUP_CONCAT(CONCAT(s.synonym_word, ':L', s.nuance_level) ORDER BY s.nuance_level, s.synonym_word SEPARATOR ' | ')
   FROM word_synonyms s
   WHERE s.word_id=w.word_id
  ) AS synonyms,

  -- 연어(최대 12개 정도)
  (SELECT GROUP_CONCAT(CONCAT(c.collocation, '(', c.freq_band, ')') ORDER BY FIELD(c.freq_band,'high','medium','low'), c.collocation SEPARATOR ' | ')
   FROM word_collocations c
   WHERE c.word_id=w.word_id
  ) AS collocations,

  -- 예문
  (SELECT GROUP_CONCAT(e.sentence ORDER BY e.ex_id SEPARATOR ' || ')
   FROM example_sentences e
   WHERE e.word_id=w.word_id AND e.ex_type='reading'
  ) AS reading_examples,

  (SELECT GROUP_CONCAT(e.sentence ORDER BY e.ex_id SEPARATOR ' || ')
   FROM example_sentences e
   WHERE e.word_id=w.word_id AND e.ex_type='speaking'
  ) AS speaking_examples

FROM words w;

DROP VIEW IF EXISTS v_root_to_derived_set;
CREATE VIEW v_root_to_derived_set AS
SELECT
  r.word_id AS root_word_id,
  r.headword AS root,
  r.pos AS root_pos,
  d.word_id AS derived_word_id,
  d.headword AS derived,
  d.pos AS derived_pos,
  d.cefr AS derived_cefr,
  d.definition_simple AS derived_definition
FROM word_family_edges e
JOIN words r ON r.word_id=e.root_word_id
JOIN words d ON d.word_id=e.derived_word_id;


/* =========================================================
   3) ✅ 빠른 확인 쿼리
   ========================================================= */

-- (1) 파생어 카드 하나 완전체 보기 (예: effective)
SELECT * FROM v_word_learning_card
WHERE headword='effective' AND pos='adj';

-- (2) root effect(n)의 파생어 세트 보기
SELECT * FROM v_root_to_derived_set
WHERE root='effect' AND root_pos='n'
ORDER BY derived;

-- (3) 파생어 중 “동의어/연어/예문” 누락 점검
SELECT
  w.headword, w.pos,
  (SELECT COUNT(*) FROM word_synonyms s WHERE s.word_id=w.word_id) AS syn_cnt,
  (SELECT COUNT(*) FROM word_collocations c WHERE c.word_id=w.word_id) AS col_cnt,
  (SELECT COUNT(*) FROM example_sentences e WHERE e.word_id=w.word_id AND e.ex_type='reading') AS read_ex_cnt,
  (SELECT COUNT(*) FROM example_sentences e WHERE e.word_id=w.word_id AND e.ex_type='speaking') AS speak_ex_cnt
FROM words w
WHERE w.is_derived=1
HAVING syn_cnt < 2 OR col_cnt < 2 OR read_ex_cnt < 1 OR speak_ex_cnt < 1
ORDER BY w.headword, w.pos;