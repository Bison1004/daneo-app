/* =========================================================
   HS1 Week1 Day1~Day7 FULL Word Family Expansion (MySQL 8+)
   - 목표: “학습앱용”으로 충분한 핵심 파생어(빈출/생산성 높은 형태)만 선별
   - 주의: derived_word는 문자열이므로, 실제 앱에서는 표제어/품사/의미를 별도 테이블로 확장 가능
   ========================================================= */

-- (권장) 중복 방지: 같은 root에 같은 derived_word가 중복 삽입되지 않도록 UNIQUE
-- ALTER TABLE word_family ADD UNIQUE KEY uq_family (word_id, derived_word);

INSERT INTO word_family (word_id, derived_word, derived_pos, derived_cefr)
SELECT w.word_id, f.derived_word, f.derived_pos, f.derived_cefr
FROM words w
JOIN (
  /* -------------------------
     Day1
     ------------------------- */
  SELECT 'cause' hw,'v/n' pos,'causal' derived_word,'adj' derived_pos,'B1' derived_cefr UNION ALL
  SELECT 'cause','v/n','cause-and-effect','n','B1' UNION ALL
  SELECT 'cause','v/n','causation','n','B2' UNION ALL
  SELECT 'cause','v/n','causative','adj','B2' UNION ALL

  SELECT 'effect','n','effective','adj','B1' UNION ALL
  SELECT 'effect','n','effectively','adv','B1' UNION ALL
  SELECT 'effect','n','effectiveness','n','B2' UNION ALL
  SELECT 'effect','n','effectless','adj','B2' UNION ALL
  SELECT 'effect','n','affect','v','B1' UNION ALL

  SELECT 'affect','v','effect','n','A2' UNION ALL
  SELECT 'affect','v','effective','adj','B1' UNION ALL
  SELECT 'affect','v','effectively','adv','B1' UNION ALL
  SELECT 'affect','v','effectiveness','n','B2' UNION ALL

  SELECT 'result','n/v','resulting','adj','B1' UNION ALL
  SELECT 'result','n/v','resultant','adj','B2' UNION ALL

  SELECT 'factor','n','factor in','v phr','B1' UNION ALL
  SELECT 'factor','n','factor out','v phr','B2' UNION ALL
  SELECT 'factor','n','factorial','adj','B2' UNION ALL

  SELECT 'increase','v/n','increasing','adj','B1' UNION ALL
  SELECT 'increase','v/n','increasingly','adv','B1' UNION ALL
  SELECT 'increase','v/n','increased','adj','B1' UNION ALL

  SELECT 'reduce','v','reduction','n','B1' UNION ALL
  SELECT 'reduce','v','reduced','adj','B1' UNION ALL
  SELECT 'reduce','v','reducible','adj','B2' UNION ALL

  SELECT 'require','v','requirement','n','B1' UNION ALL
  SELECT 'require','v','required','adj','A2+' UNION ALL
  SELECT 'require','v','requirement(s)','n','B1' UNION ALL

  SELECT 'solution','n','solve','v','B1' UNION ALL
  SELECT 'solution','n','solved','adj','B1' UNION ALL
  SELECT 'solution','n','solvable','adj','B2' UNION ALL
  SELECT 'solution','n','unsolved','adj','B2' UNION ALL

  SELECT 'impact','n/v','impactful','adj','B2' UNION ALL
  SELECT 'impact','n/v','impacted','adj','B1' UNION ALL
  SELECT 'impact','n/v','impacting','adj','B1' UNION ALL

  /* -------------------------
     Day2
     ------------------------- */
  SELECT 'issue','n','issues','n(pl)','A2' UNION ALL
  SELECT 'issue','n','issue (v: to issue)','v','B2' UNION ALL

  SELECT 'challenge','n','challenging','adj','B1' UNION ALL
  SELECT 'challenge','n','challenger','n','B2' UNION ALL
  SELECT 'challenge','n','challenge (v)','v','B1' UNION ALL

  SELECT 'prevent','v','prevention','n','B1' UNION ALL
  SELECT 'prevent','v','preventive','adj','B2' UNION ALL
  SELECT 'prevent','v','preventable','adj','B2' UNION ALL

  SELECT 'avoid','v','avoidable','adj','B1' UNION ALL
  SELECT 'avoid','v','avoidance','n','B2' UNION ALL
  SELECT 'avoid','v','avoidant','adj','B2' UNION ALL

  SELECT 'manage','v','management','n','B1' UNION ALL
  SELECT 'manage','v','manager','n','B1' UNION ALL
  SELECT 'manage','v','manageable','adj','B2' UNION ALL
  SELECT 'manage','v','managed','adj','B1' UNION ALL

  SELECT 'support','v/n','supportive','adj','B1' UNION ALL
  SELECT 'support','v/n','supporter','n','B1' UNION ALL
  SELECT 'support','v/n','unsupported','adj','B2' UNION ALL

  SELECT 'suggest','v','suggestion','n','B1' UNION ALL
  SELECT 'suggest','v','suggestive','adj','B2' UNION ALL
  SELECT 'suggest','v','suggested','adj','B1' UNION ALL

  SELECT 'strategy','n','strategic','adj','B2' UNION ALL
  SELECT 'strategy','n','strategically','adv','B2' UNION ALL
  SELECT 'strategy','n','strategist','n','B2' UNION ALL

  SELECT 'risk','n','risky','adj','B1' UNION ALL
  SELECT 'risk','n','riskiness','n','B2' UNION ALL
  SELECT 'risk','n','risk (v)','v','B1' UNION ALL

  SELECT 'benefit','n/v','beneficial','adj','B1' UNION ALL
  SELECT 'benefit','n/v','benefit (v)','v','A2+' UNION ALL
  SELECT 'benefit','n/v','beneficiary','n','B2' UNION ALL

  /* -------------------------
     Day3
     ------------------------- */
  SELECT 'evidence','n','evident','adj','B1' UNION ALL
  SELECT 'evidence','n','evidently','adv','B2' UNION ALL
  SELECT 'evidence','n','evidential','adj','B2' UNION ALL

  SELECT 'claim','n/v','claimed','adj','B1' UNION ALL
  SELECT 'claim','n/v','claimant','n','B2' UNION ALL
  SELECT 'claim','n/v','reclaim','v','B2' UNION ALL

  SELECT 'argue','v','argument','n','B1' UNION ALL
  SELECT 'argue','v','argumentative','adj','B2' UNION ALL
  SELECT 'argue','v','arguably','adv','B2' UNION ALL

  SELECT 'conclude','v','conclusion','n','B1' UNION ALL
  SELECT 'conclude','v','conclusive','adj','B2' UNION ALL
  SELECT 'conclude','v','inconclusive','adj','B2' UNION ALL

  SELECT 'indicate','v','indication','n','B1' UNION ALL
  SELECT 'indicate','v','indicative','adj','B2' UNION ALL
  SELECT 'indicate','v','indicator','n','B2' UNION ALL

  SELECT 'research','n/v','researcher','n','B1' UNION ALL
  SELECT 'research','n/v','research-based','adj','B2' UNION ALL
  SELECT 'research','n/v','researched','adj','B2' UNION ALL

  SELECT 'data','n','database','n','B1' UNION ALL
  SELECT 'data','n','data-driven','adj','B2' UNION ALL

  SELECT 'trend','n','trendy','adj','B1' UNION ALL
  SELECT 'trend','n','trendiness','n','B2' UNION ALL

  /* -------------------------
     Day4
     ------------------------- */
  SELECT 'process','n','process (v)','v','B1' UNION ALL
  SELECT 'process','n','processing','n/adj','B1' UNION ALL
  SELECT 'process','n','processed','adj','B1' UNION ALL

  SELECT 'method','n','methodical','adj','B2' UNION ALL
  SELECT 'method','n','methodically','adv','B2' UNION ALL

  SELECT 'step','n','step-by-step','adj','A2+' UNION ALL
  SELECT 'step','n','stepping-stone','n','B2' UNION ALL

  SELECT 'practice','n/v','practical','adj','B1' UNION ALL
  SELECT 'practice','n/v','practically','adv','B1' UNION ALL
  SELECT 'practice','n/v','practitioner','n','B2' UNION ALL

  SELECT 'improve','v','improvement','n','B1' UNION ALL
  SELECT 'improve','v','improved','adj','B1' UNION ALL
  SELECT 'improve','v','improving','adj','B1' UNION ALL

  SELECT 'maintain','v','maintenance','n','B2' UNION ALL
  SELECT 'maintain','v','maintained','adj','B1' UNION ALL
  SELECT 'maintain','v','maintainable','adj','B2' UNION ALL

  SELECT 'focus','v/n','focused','adj','B1' UNION ALL
  SELECT 'focus','v/n','focus on','v phr','A2+' UNION ALL
  SELECT 'focus','v/n','focal','adj','B2' UNION ALL

  SELECT 'review','v/n','reviewer','n','B2' UNION ALL
  SELECT 'review','v/n','reviewed','adj','B2' UNION ALL
  SELECT 'review','v/n','revise','v','B1' UNION ALL
  SELECT 'review','v/n','revision','n','B1' UNION ALL

  SELECT 'consistency','n','consistent','adj','B1' UNION ALL
  SELECT 'consistency','n','consistently','adv','B1' UNION ALL
  SELECT 'consistency','n','inconsistent','adj','B2' UNION ALL
  SELECT 'consistency','n','inconsistency','n','B2' UNION ALL

  SELECT 'goal','n','goal-setting','n','B1' UNION ALL
  SELECT 'goal','n','goal-oriented','adj','B2' UNION ALL

  /* -------------------------
     Day5
     ------------------------- */
  SELECT 'compare','v','comparison','n','B1' UNION ALL
  SELECT 'compare','v','comparative','adj','B1' UNION ALL
  SELECT 'compare','v','comparatively','adv','B2' UNION ALL

  SELECT 'contrast','v/n','contrasting','adj','B1' UNION ALL
  SELECT 'contrast','v/n','contrasted','adj','B1' UNION ALL

  SELECT 'similar','adj','similarity','n','B1' UNION ALL
  SELECT 'similar','adj','similarly','adv','B1' UNION ALL
  SELECT 'similar','adj','dissimilar','adj','B2' UNION ALL

  SELECT 'different','adj','difference','n','A2+' UNION ALL
  SELECT 'different','adj','differ','v','B1' UNION ALL
  SELECT 'different','adj','differently','adv','B1' UNION ALL

  SELECT 'advantage','n','advantageous','adj','B2' UNION ALL
  SELECT 'advantage','n','disadvantage','n','B1' UNION ALL

  SELECT 'disadvantage','n','disadvantaged','adj','B2' UNION ALL

  SELECT 'prefer','v','preference','n','B1' UNION ALL
  SELECT 'prefer','v','preferable','adj','B2' UNION ALL
  SELECT 'prefer','v','preferably','adv','B2' UNION ALL

  SELECT 'option','n','optional','adj','B1' UNION ALL
  SELECT 'option','n','optionally','adv','B2' UNION ALL

  SELECT 'balance','n/v','balanced','adj','B1' UNION ALL
  SELECT 'balance','n/v','imbalance','n','B2' UNION ALL
  SELECT 'balance','n/v','unbalanced','adj','B2' UNION ALL

  SELECT 'efficient','adj','efficiency','n','B1' UNION ALL
  SELECT 'efficient','adj','efficiently','adv','B1' UNION ALL
  SELECT 'efficient','adj','inefficient','adj','B2' UNION ALL
  SELECT 'efficient','adj','inefficiency','n','B2' UNION ALL

  /* -------------------------
     Day6
     ------------------------- */
  SELECT 'opinion','n','opinionated','adj','B2' UNION ALL

  SELECT 'reason','n','reasonable','adj','B1' UNION ALL
  SELECT 'reason','n','reasonably','adv','B1' UNION ALL
  SELECT 'reason','n','reasoning','n','B2' UNION ALL

  SELECT 'example','n','exemplary','adj','B2' UNION ALL
  SELECT 'example','n','for example','phr','A2' UNION ALL

  SELECT 'explain','v','explanation','n','B1' UNION ALL
  SELECT 'explain','v','explanatory','adj','B2' UNION ALL
  SELECT 'explain','v','unexplained','adj','B2' UNION ALL

  SELECT 'recommend','v','recommendation','n','B1' UNION ALL
  SELECT 'recommend','v','recommended','adj','B1' UNION ALL

  SELECT 'decide','v','decision','n','B1' UNION ALL
  SELECT 'decide','v','decisive','adj','B2' UNION ALL
  SELECT 'decide','v','indecisive','adj','B2' UNION ALL

  SELECT 'pressure','n','pressured','adj','B1' UNION ALL
  SELECT 'pressure','n','pressurize','v','B2' UNION ALL

  SELECT 'motivate','v','motivation','n','B1' UNION ALL
  SELECT 'motivate','v','motivated','adj','B1' UNION ALL
  SELECT 'motivate','v','motivating','adj','B1' UNION ALL

  SELECT 'confidence','n','confident','adj','B1' UNION ALL
  SELECT 'confidence','n','confidently','adv','B1' UNION ALL

  SELECT 'habit','n','habitual','adj','B2' UNION ALL
  SELECT 'habit','n','habitually','adv','B2' UNION ALL

  /* -------------------------
     Day7
     ------------------------- */
  SELECT 'agree','v','agreement','n','B1' UNION ALL
  SELECT 'agree','v','agreeable','adj','B2' UNION ALL
  SELECT 'agree','v','agreeably','adv','B2' UNION ALL
  SELECT 'agree','v','disagree','v','A2+' UNION ALL

  SELECT 'disagree','v','disagreement','n','B1' UNION ALL
  SELECT 'disagree','v','disagreeable','adj','B2' UNION ALL

  SELECT 'however','adv','however (conj-like use)','adv','B1' UNION ALL

  SELECT 'although','conj','though','conj','B1' UNION ALL
  SELECT 'although','conj','even though','conj','B1' UNION ALL

  SELECT 'consider','v','consideration','n','B1' UNION ALL
  SELECT 'consider','v','considerate','adj','B2' UNION ALL
  SELECT 'consider','v','considerably','adv','B2' UNION ALL
  SELECT 'consider','v','considering','prep/conj','B2' UNION ALL

  SELECT 'perspective','n','perspectival','adj','B2' UNION ALL

  SELECT 'limit','v/n','limitation','n','B2' UNION ALL
  SELECT 'limit','v/n','limited','adj','B1' UNION ALL
  SELECT 'limit','v/n','limitless','adj','B2' UNION ALL

  SELECT 'necessary','adj','necessity','n','B2' UNION ALL
  SELECT 'necessary','adj','necessarily','adv','B2' UNION ALL
  SELECT 'necessary','adj','unnecessary','adj','B1' UNION ALL

  SELECT 'effective','adj','effectively','adv','B1' UNION ALL
  SELECT 'effective','adj','effectiveness','n','B2' UNION ALL
  SELECT 'effective','adj','ineffective','adj','B2'
) f
ON w.headword=f.hw AND w.pos=f.pos
-- 중복 삽입 방지(UNIQUE 없을 때 안전장치)
LEFT JOIN word_family wf ON wf.word_id=w.word_id AND wf.derived_word=f.derived_word
WHERE wf.family_id IS NULL;