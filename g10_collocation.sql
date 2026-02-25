/* =========================================================
   HS1 Week1 Derived Words (A안): Collocations 정교화 SQL
   - 목적: 파생어(word.is_derived=1)에 대해 “실제 빈출 연어”를 삽입
   - 안전: 기존 placeholder( "... + (common pattern)" )는 삭제 후 재삽입
   ========================================================= */

START TRANSACTION;

-- 0) 파생어 placeholder 연어 제거
DELETE wc
FROM word_collocations wc
JOIN words w ON w.word_id = wc.word_id
WHERE w.is_derived=1
  AND wc.collocation LIKE '%(common pattern)%';

/* =========================================================
   1) 파생어 연어 INSERT
   - freq_band: high/medium/low (학습 우선순위)
   ========================================================= */

INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  /* -------------------------
     cause-family
     ------------------------- */
  SELECT 'causal' hw,'adj' pos,'causal relationship' col,'high' fb UNION ALL
  SELECT 'causal','adj','causal link' ,'high' UNION ALL
  SELECT 'causal','adj','causal factor','medium' UNION ALL

  SELECT 'causation' hw,'n' pos,'correlation and causation' col,'high' fb UNION ALL
  SELECT 'causation','n','the problem of causation','low' UNION ALL

  SELECT 'cause-and-effect' hw,'n' pos,'cause-and-effect relationship' col,'high' fb UNION ALL
  SELECT 'cause-and-effect','n','cause-and-effect reasoning' col,'medium' UNION ALL

  /* -------------------------
     effect-family
     ------------------------- */
  SELECT 'effective' hw,'adj' pos,'an effective way' col,'high' fb UNION ALL
  SELECT 'effective','adj','highly effective' col,'high' UNION ALL
  SELECT 'effective','adj','effective for' col,'high' UNION ALL
  SELECT 'effective','adj','effective in' col,'medium' UNION ALL

  SELECT 'effectively' hw,'adv' pos,'work effectively' col,'high' fb UNION ALL
  SELECT 'effectively','adv','communicate effectively' col,'high' UNION ALL
  SELECT 'effectively','adv','deal with effectively' col,'medium' UNION ALL
  SELECT 'effectively','adv','use (time/resources) effectively' col,'high' UNION ALL

  SELECT 'effectiveness' hw,'n' pos,'the effectiveness of' col,'high' fb UNION ALL
  SELECT 'effectiveness','n','measure effectiveness' col,'medium' UNION ALL
  SELECT 'effectiveness','n','prove effectiveness' col,'medium' UNION ALL

  SELECT 'ineffective' hw,'adj' pos,'ineffective at' col,'medium' fb UNION ALL
  SELECT 'ineffective','adj','largely ineffective' col,'medium' UNION ALL
  SELECT 'ineffective','adj','ineffective method' col,'high' UNION ALL

  /* -------------------------
     increase/reduce/require/solution
     ------------------------- */
  SELECT 'increasing' hw,'adj' pos,'increasing number of' col,'high' fb UNION ALL
  SELECT 'increasing','adj','increasing demand for' col,'high' UNION ALL
  SELECT 'increasing','adj','an increasing trend' col,'medium' UNION ALL

  SELECT 'increasingly' hw,'adv' pos,'increasingly common' col,'medium' fb UNION ALL
  SELECT 'increasingly','adv','increasingly important' col,'high' UNION ALL
  SELECT 'increasingly','adv','increasingly difficult' col,'medium' UNION ALL

  SELECT 'reduction' hw,'n' pos,'a reduction in' col,'high' fb UNION ALL
  SELECT 'reduction','n','significant reduction' col,'medium' UNION ALL
  SELECT 'reduction','n','reduce (something) by a reduction' col,'low' UNION ALL

  SELECT 'required' hw,'adj' pos,'be required to' col,'high' fb UNION ALL
  SELECT 'required','adj','required for' col,'high' UNION ALL
  SELECT 'required','adj','required reading' col,'medium' UNION ALL

  SELECT 'requirement' hw,'n' pos,'meet the requirement' col,'high' fb UNION ALL
  SELECT 'requirement','n','minimum requirement' col,'high' UNION ALL
  SELECT 'requirement','n','basic requirement' col,'medium' UNION ALL
  SELECT 'requirement','n','entry requirement' col,'medium' UNION ALL

  SELECT 'solve' hw,'v' pos,'solve a problem' col,'high' fb UNION ALL
  SELECT 'solve','v','solve the issue' col,'high' UNION ALL
  SELECT 'solve','v','solve quickly' col,'low' UNION ALL

  SELECT 'solvable' hw,'adj' pos,'a solvable problem' col,'high' fb UNION ALL
  SELECT 'solvable','adj','easily solvable' col,'medium' UNION ALL

  SELECT 'unsolved' hw,'adj' pos,'unsolved problem' col,'high' fb UNION ALL
  SELECT 'unsolved','adj','remain unsolved' col,'high' UNION ALL

  /* -------------------------
     Day2 derived: prevention/preventive/avoidable/avoidance/supportive/suggestion/strategy/risky/beneficial/beneficiary
     ------------------------- */
  SELECT 'prevention' hw,'n' pos,'disease prevention' col,'high' fb UNION ALL
  SELECT 'prevention','n','prevention of' col,'high' UNION ALL
  SELECT 'prevention','n','prevention measures' col,'medium' UNION ALL

  SELECT 'preventive' hw,'adj' pos,'preventive measures' col,'high' fb UNION ALL
  SELECT 'preventive','adj','preventive action' col,'medium' UNION ALL

  SELECT 'avoidable' hw,'adj' pos,'avoidable mistake' col,'high' fb UNION ALL
  SELECT 'avoidable','adj','largely avoidable' col,'medium' UNION ALL

  SELECT 'avoidance' hw,'n' pos,'avoidance of' col,'high' fb UNION ALL
  SELECT 'avoidance','n','avoidance behavior' col,'medium' UNION ALL

  SELECT 'supportive' hw,'adj' pos,'supportive environment' col,'high' fb UNION ALL
  SELECT 'supportive','adj','supportive parents' col,'medium' UNION ALL
  SELECT 'supportive','adj','be supportive of' col,'high' UNION ALL

  SELECT 'suggestion' hw,'n' pos,'make a suggestion' col,'high' fb UNION ALL
  SELECT 'suggestion','n','helpful suggestion' col,'high' UNION ALL
  SELECT 'suggestion','n','follow a suggestion' col,'medium' UNION ALL

  SELECT 'strategic' hw,'adj' pos,'strategic plan' col,'high' fb UNION ALL
  SELECT 'strategic','adj','strategic decision' col,'high' UNION ALL
  SELECT 'strategic','adj','strategic choice' col,'medium' UNION ALL

  SELECT 'strategically' hw,'adv' pos,'think strategically' col,'high' fb UNION ALL
  SELECT 'strategically','adv','plan strategically' col,'high' UNION ALL

  SELECT 'strategist' hw,'n' pos,'political strategist' col,'medium' fb UNION ALL
  SELECT 'strategist','n','marketing strategist' col,'medium' UNION ALL

  SELECT 'risky' hw,'adj' pos,'risky behavior' col,'high' fb UNION ALL
  SELECT 'risky','adj','too risky to' col,'medium' UNION ALL

  SELECT 'beneficial' hw,'adj' pos,'beneficial for' col,'high' fb UNION ALL
  SELECT 'beneficial','adj','highly beneficial' col,'medium' UNION ALL
  SELECT 'beneficial','adj','beneficial effect' col,'medium' UNION ALL

  SELECT 'beneficiary' hw,'n' pos,'the main beneficiary' col,'high' fb UNION ALL
  SELECT 'beneficiary','n','beneficiary of' col,'high' UNION ALL

  /* -------------------------
     Day3 derived: evident/evidently/argument/conclusion/indication/researcher/database/research-based/data-driven
     ------------------------- */
  SELECT 'evident' hw,'adj' pos,'it is evident that' col,'high' fb UNION ALL
  SELECT 'evident','adj','become evident' col,'medium' UNION ALL

  SELECT 'evidently' hw,'adv' pos,'evidently, (sentence)' col,'high' fb UNION ALL
  SELECT 'evidently','adv','quite evidently' col,'low' UNION ALL

  SELECT 'argument' hw,'n' pos,'make an argument' col,'high' fb UNION ALL
  SELECT 'argument','n','strong argument' col,'high' UNION ALL
  SELECT 'argument','n','argument for/against' col,'high' UNION ALL

  SELECT 'conclusion' hw,'n' pos,'draw a conclusion' col,'high' fb UNION ALL
  SELECT 'conclusion','n','reach a conclusion' col,'high' UNION ALL
  SELECT 'conclusion','n','in conclusion' col,'high' UNION ALL

  SELECT 'indication' hw,'n' pos,'a clear indication' col,'high' fb UNION ALL
  SELECT 'indication','n','indication of' col,'high' UNION ALL

  SELECT 'researcher' hw,'n' pos,'researcher found that' col,'high' fb UNION ALL
  SELECT 'researcher','n','lead researcher' col,'medium' UNION ALL

  SELECT 'database' hw,'n' pos,'database system' col,'medium' fb UNION ALL
  SELECT 'database','n','store in a database' col,'high' UNION ALL
  SELECT 'database','n','database of' col,'high' UNION ALL

  SELECT 'research-based' hw,'adj' pos,'research-based approach' col,'high' fb UNION ALL
  SELECT 'research-based','adj','research-based learning' col,'medium' UNION ALL

  SELECT 'data-driven' hw,'adj' pos,'data-driven approach' col,'high' fb UNION ALL
  SELECT 'data-driven','adj','data-driven decision' col,'high' UNION ALL
  SELECT 'data-driven','adj','data-driven insights' col,'medium' UNION ALL

  /* -------------------------
     Day4 derived: methodical/practical/improvement/maintenance/focused/revision/consistent/consistently/goal-setting
     ------------------------- */
  SELECT 'methodical' hw,'adj' pos,'methodical approach' col,'high' fb UNION ALL
  SELECT 'methodical','adj','methodical way' col,'medium' UNION ALL

  SELECT 'practical' hw,'adj' pos,'practical advice' col,'high' fb UNION ALL
  SELECT 'practical','adj','practical skills' col,'high' UNION ALL
  SELECT 'practical','adj','practical solution' col,'medium' UNION ALL

  SELECT 'improvement' hw,'n' pos,'show improvement' col,'high' fb UNION ALL
  SELECT 'improvement','n','significant improvement' col,'high' UNION ALL
  SELECT 'improvement','n','room for improvement' col,'high' UNION ALL

  SELECT 'maintenance' hw,'n' pos,'regular maintenance' col,'high' fb UNION ALL
  SELECT 'maintenance','n','require maintenance' col,'medium' UNION ALL

  SELECT 'focused' hw,'adj' pos,'stay focused' col,'high' fb UNION ALL
  SELECT 'focused','adj','highly focused' col,'medium' UNION ALL

  SELECT 'revision' hw,'n' pos,'do a revision' col,'medium' fb UNION ALL
  SELECT 'revision','n','revision of' col,'high' UNION ALL
  SELECT 'revision','n','final revision' col,'high' UNION ALL

  SELECT 'consistent' hw,'adj' pos,'consistent effort' col,'high' fb UNION ALL
  SELECT 'consistent','adj','consistent results' col,'medium' UNION ALL

  SELECT 'consistently' hw,'adv' pos,'perform consistently' col,'medium' fb UNION ALL
  SELECT 'consistently','adv','work consistently' col,'high' UNION ALL

  SELECT 'goal-setting' hw,'n' pos,'goal-setting strategy' col,'medium' fb UNION ALL
  SELECT 'goal-setting','n','goal-setting process' col,'medium' UNION ALL

  /* -------------------------
     Day5 derived: comparison/comparative/similarity/difference/differ/preference/optional/balanced/efficiency
     ------------------------- */
  SELECT 'comparison' hw,'n' pos,'in comparison' col,'high' fb UNION ALL
  SELECT 'comparison','n','by comparison' col,'high' UNION ALL
  SELECT 'comparison','n','make a comparison' col,'high' UNION ALL

  SELECT 'comparative' hw,'adj' pos,'comparative study' col,'high' fb UNION ALL
  SELECT 'comparative','adj','comparative analysis' col,'high' UNION ALL

  SELECT 'similarity' hw,'n' pos,'similarity between' col,'high' fb UNION ALL
  SELECT 'similarity','n','share a similarity' col,'medium' UNION ALL

  SELECT 'difference' hw,'n' pos,'difference between' col,'high' fb UNION ALL
  SELECT 'difference','n','make a difference' col,'high' UNION ALL
  SELECT 'difference','n','tell the difference' col,'medium' UNION ALL

  SELECT 'differ' hw,'v' pos,'differ from' col,'high' fb UNION ALL
  SELECT 'differ','v','differ in' col,'high' UNION ALL

  SELECT 'preference' hw,'n' pos,'personal preference' col,'high' fb UNION ALL
  SELECT 'preference','n','preference for' col,'high' UNION ALL

  SELECT 'optional' hw,'adj' pos,'optional course' col,'medium' fb UNION ALL
  SELECT 'optional','adj','optional activity' col,'medium' UNION ALL

  SELECT 'balanced' hw,'adj' pos,'balanced diet' col,'high' fb UNION ALL
  SELECT 'balanced','adj','balanced schedule' col,'high' UNION ALL
  SELECT 'balanced','adj','keep (things) balanced' col,'medium' UNION ALL

  SELECT 'efficiency' hw,'n' pos,'improve efficiency' col,'high' fb UNION ALL
  SELECT 'efficiency','n','increase efficiency' col,'high' UNION ALL
  SELECT 'efficiency','n','operational efficiency' col,'low' UNION ALL

  /* -------------------------
     Day6 derived: recommendation/decision/motivation/confident/confidently
     ------------------------- */
  SELECT 'recommendation' hw,'n' pos,'follow a recommendation' col,'medium' fb UNION ALL
  SELECT 'recommendation','n','strong recommendation' col,'medium' UNION ALL

  SELECT 'decision' hw,'n' pos,'make a decision' col,'high' fb UNION ALL
  SELECT 'decision','n','final decision' col,'high' UNION ALL
  SELECT 'decision','n','difficult decision' col,'high' UNION ALL

  SELECT 'motivation' hw,'n' pos,'motivation to' col,'high' fb UNION ALL
  SELECT 'motivation','n','lack motivation' col,'medium' UNION ALL
  SELECT 'motivation','n','increase motivation' col,'high' UNION ALL

  SELECT 'confident' hw,'adj' pos,'feel confident' col,'high' fb UNION ALL
  SELECT 'confident','adj','confident about' col,'high' UNION ALL

  SELECT 'confidently' hw,'adv' pos,'speak confidently' col,'high' fb UNION ALL
  SELECT 'confidently','adv','answer confidently' col,'medium' UNION ALL

  /* -------------------------
     Day7 derived: agreement/disagreement/limitation/necessity/unnecessary/imbalance/unbalanced
     ------------------------- */
  SELECT 'agreement' hw,'n' pos,'reach an agreement' col,'high' fb UNION ALL
  SELECT 'agreement','n','in agreement' col,'high' UNION ALL

  SELECT 'disagreement' hw,'n' pos,'have a disagreement' col,'high' fb UNION ALL
  SELECT 'disagreement','n','disagreement about/over' col,'high' UNION ALL

  SELECT 'limitation' hw,'n' pos,'a major limitation' col,'high' fb UNION ALL
  SELECT 'limitation','n','limitation of' col,'high' UNION ALL

  SELECT 'necessity' hw,'n' pos,'out of necessity' col,'medium' fb UNION ALL
  SELECT 'necessity','n','a necessity for' col,'high' UNION ALL

  SELECT 'unnecessary' hw,'adj' pos,'unnecessary stress' col,'high' fb UNION ALL
  SELECT 'unnecessary','adj','completely unnecessary' col,'medium' UNION ALL

  SELECT 'imbalance' hw,'n' pos,'imbalance between' col,'high' fb UNION ALL
  SELECT 'imbalance','n','serious imbalance' col,'medium' UNION ALL

  SELECT 'unbalanced' hw,'adj' pos,'an unbalanced diet' col,'high' fb UNION ALL
  SELECT 'unbalanced','adj','unbalanced schedule' col,'medium'
) x ON x.hw=w.headword AND x.pos=w.pos
WHERE w.is_derived=1;

COMMIT;


/* =========================================================
   ✅ 검증 쿼리
   ========================================================= */

-- 파생어 연어가 얼마나 들어갔는지
SELECT COUNT(*) AS derived_collocations
FROM word_collocations wc
JOIN words w ON w.word_id=wc.word_id
WHERE w.is_derived=1;

-- 특정 파생어(예: decision)의 연어 확인
SELECT w.headword, w.pos, wc.collocation, wc.freq_band
FROM words w
JOIN word_collocations wc ON wc.word_id=w.word_id
WHERE w.headword='decision' AND w.pos='n' AND w.is_derived=1
ORDER BY wc.freq_band DESC, wc.collocation;