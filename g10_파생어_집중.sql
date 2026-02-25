/* =========================================================
   HS1 Week1 Derived Words (A안): definition + examples 정교화
   - [AUTO] placeholder를 실제 학습용으로 교체
   ========================================================= */

START TRANSACTION;

/* 0) 파생어 [AUTO] 예문 삭제 (Week1 파생어 카드만)
   - 안전하게 is_derived=1 인 단어의 [AUTO] 예문만 제거
*/
DELETE ex
FROM example_sentences ex
JOIN words w ON w.word_id = ex.word_id
WHERE w.is_derived = 1
  AND ex.sentence LIKE '[AUTO]%';


/* =========================================================
   1) DEFINITIONS: 파생어(words.definition_simple) 업데이트
   - headword+pos 기반으로 업데이트
   - 필요시 cefr도 함께 보정 가능(여기선 정의 중심)
   ========================================================= */

-- Cause-family
UPDATE words SET definition_simple='related to cause and effect' 
WHERE headword='causal' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='the process of causing something; cause-and-effect relationship' 
WHERE headword='causation' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a cause-and-effect relationship (as a concept)' 
WHERE headword='cause-and-effect' AND pos='n' AND is_derived=1;

-- Effect-family
UPDATE words SET definition_simple='producing the intended result; successful'
WHERE headword='effective' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='in a way that produces good results'
WHERE headword='effectively' AND pos='adv' AND is_derived=1;

UPDATE words SET definition_simple='how well something works; the ability to produce results'
WHERE headword='effectiveness' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='not producing results; not effective'
WHERE headword='ineffective' AND pos='adj' AND is_derived=1;

-- Increase / Reduce / Require / Solution
UPDATE words SET definition_simple='becoming greater; growing'
WHERE headword='increasing' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='more and more; to an increasing degree'
WHERE headword='increasingly' AND pos='adv' AND is_derived=1;

UPDATE words SET definition_simple='a decrease in size, amount, or number'
WHERE headword='reduction' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='needed or demanded; must be done'
WHERE headword='required' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='something you need; a rule or condition that must be met'
WHERE headword='requirement' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='to find the answer to a problem; to deal with a difficulty'
WHERE headword='solve' AND pos='v' AND is_derived=1;

UPDATE words SET definition_simple='able to be solved'
WHERE headword='solvable' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='not yet solved'
WHERE headword='unsolved' AND pos='adj' AND is_derived=1;

-- Day2 (prevent/avoid/support/suggest/strategy/risk/benefit)
UPDATE words SET definition_simple='stopping something bad from happening'
WHERE headword='prevention' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='intended to prevent problems or disease'
WHERE headword='preventive' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='able to be avoided or prevented'
WHERE headword='avoidable' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='a way of avoiding something; the act of avoiding'
WHERE headword='avoidance' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='giving help and encouragement'
WHERE headword='supportive' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='an idea or piece of advice about what to do'
WHERE headword='suggestion' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='related to planning for a goal in a smart way'
WHERE headword='strategic' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='in a strategic way'
WHERE headword='strategically' AND pos='adv' AND is_derived=1;

UPDATE words SET definition_simple='a person who makes plans for success (often in politics/business)'
WHERE headword='strategist' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='likely to cause danger or loss'
WHERE headword='risky' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='helpful; producing good results'
WHERE headword='beneficial' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='a person who receives help or benefits'
WHERE headword='beneficiary' AND pos='n' AND is_derived=1;

-- Day3 (evidence/argue/conclude/indicate/research/data)
UPDATE words SET definition_simple='easy to see or understand; clear'
WHERE headword='evident' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='clearly; obviously'
WHERE headword='evidently' AND pos='adv' AND is_derived=1;

UPDATE words SET definition_simple='a reasoned discussion; a set of reasons supporting a view'
WHERE headword='argument' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a final decision or result of thinking; the ending part'
WHERE headword='conclusion' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a sign that something exists or is true'
WHERE headword='indication' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a person who does research'
WHERE headword='researcher' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a collection of organized data, often in a computer system'
WHERE headword='database' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='based on research and evidence'
WHERE headword='research-based' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='based on data; using data to make decisions'
WHERE headword='data-driven' AND pos='adj' AND is_derived=1;

-- Day4 (process/method/practice/improve/maintain/focus/review/consistency/goal)
UPDATE words SET definition_simple='done in a careful and organized way'
WHERE headword='methodical' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='useful in real situations; not only theoretical'
WHERE headword='practical' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='a change that makes something better'
WHERE headword='improvement' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='work needed to keep something in good condition'
WHERE headword='maintenance' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='paying close attention; not distracted'
WHERE headword='focused' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='the act of revising; a changed version'
WHERE headword='revision' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='regular and steady; not changing often'
WHERE headword='consistent' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='in a steady and regular way'
WHERE headword='consistently' AND pos='adv' AND is_derived=1;

UPDATE words SET definition_simple='planning how to reach goals'
WHERE headword='goal-setting' AND pos='n' AND is_derived=1;

-- Day5 (compare/contrast/similar/different/advantage/prefer/option/balance/efficient)
UPDATE words SET definition_simple='the act of comparing; a look at similarities and differences'
WHERE headword='comparison' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='used for comparing; showing similarities and differences'
WHERE headword='comparative' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='the state of being similar'
WHERE headword='similarity' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a difference; the state of not being the same'
WHERE headword='difference' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='to be different (often with “from”)'
WHERE headword='differ' AND pos='v' AND is_derived=1;

UPDATE words SET definition_simple='what someone likes or chooses more than something else'
WHERE headword='preference' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='not required; you can choose it'
WHERE headword='optional' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='in a healthy or equal state; not extreme'
WHERE headword='balanced' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='how well something uses time/energy; being efficient'
WHERE headword='efficiency' AND pos='n' AND is_derived=1;

-- Day6 (recommend/decide/motivate/confidence)
UPDATE words SET definition_simple='a suggestion about what should be done'
WHERE headword='recommendation' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a choice you make after thinking'
WHERE headword='decision' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='the reason or desire to do something'
WHERE headword='motivation' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='feeling sure that you can do something well'
WHERE headword='confident' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='in a confident way'
WHERE headword='confidently' AND pos='adv' AND is_derived=1;

-- Day7 (agree/disagree/limit/necessary)
UPDATE words SET definition_simple='a situation where people have the same opinion'
WHERE headword='agreement' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a situation where people have different opinions'
WHERE headword='disagreement' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='a rule or condition that restricts something; a weakness'
WHERE headword='limitation' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='something that is needed; something necessary'
WHERE headword='necessity' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='not necessary'
WHERE headword='unnecessary' AND pos='adj' AND is_derived=1;

UPDATE words SET definition_simple='the state of not having balance'
WHERE headword='imbalance' AND pos='n' AND is_derived=1;

UPDATE words SET definition_simple='not balanced; not in a healthy/equal state'
WHERE headword='unbalanced' AND pos='adj' AND is_derived=1;


/* =========================================================
   2) EXAMPLES: 파생어 예문 2개씩 (reading / speaking)
   - 단어별로 "수능식 문장 + 말하기 확장 문장"
   ========================================================= */

INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  -- causal / causation
  SELECT 'causal' hw,'adj' pos,'reading' ex_type,'The study found a causal link between sleep and memory.' sentence UNION ALL
  SELECT 'causal','adj','speaking','There is a causal relationship between practice and confidence.' UNION ALL

  SELECT 'causation' hw,'n' pos,'reading','Correlation does not always mean causation.' UNION ALL
  SELECT 'causation','n','speaking','I want to understand the causation behind my mistakes.' UNION ALL

  -- effective / effectively / effectiveness / ineffective
  SELECT 'effective' hw,'adj' pos,'reading','Spaced repetition is an effective method for vocabulary learning.' UNION ALL
  SELECT 'effective','adj','speaking','This routine is effective because it saves time.' UNION ALL

  SELECT 'effectively' hw,'adv' pos,'reading','Students can learn more effectively with clear goals.' UNION ALL
  SELECT 'effectively','adv','speaking','I use my time effectively by studying in short sessions.' UNION ALL

  SELECT 'effectiveness' hw,'n' pos,'reading','Researchers tested the effectiveness of the new teaching method.' UNION ALL
  SELECT 'effectiveness','n','speaking','The effectiveness of my plan depends on consistency.' UNION ALL

  SELECT 'ineffective' hw,'adj' pos,'reading','Cramming can be ineffective for long-term memory.' UNION ALL
  SELECT 'ineffective','adj','speaking','Studying without review is ineffective for me.' UNION ALL

  -- increasing / increasingly
  SELECT 'increasing' hw,'adj' pos,'reading','There is an increasing demand for online education.' UNION ALL
  SELECT 'increasing','adj','speaking','I feel increasing pressure before exams.' UNION ALL

  SELECT 'increasingly' hw,'adv' pos,'reading','Students are increasingly using AI tools for learning.' UNION ALL
  SELECT 'increasingly','adv','speaking','I am increasingly interested in speaking practice.' UNION ALL

  -- reduction
  SELECT 'reduction' hw,'n' pos,'reading','A reduction in screen time can improve sleep quality.' UNION ALL
  SELECT 'reduction','n','speaking','I noticed a reduction in stress after daily exercise.' UNION ALL

  -- required / requirement
  SELECT 'required' hw,'adj' pos,'reading','Students are required to submit the assignment by Friday.' UNION ALL
  SELECT 'required','adj','speaking','Regular practice is required if you want real progress.' UNION ALL

  SELECT 'requirement' hw,'n' pos,'reading','One graduation requirement is passing an English test.' UNION ALL
  SELECT 'requirement','n','speaking','My main requirement for a study plan is consistency.' UNION ALL

  -- solve / solvable / unsolved
  SELECT 'solve' hw,'v' pos,'reading','Scientists work to solve complex problems step by step.' UNION ALL
  SELECT 'solve','v','speaking','I try to solve my weak points by reviewing daily.' UNION ALL

  SELECT 'solvable' hw,'adj' pos,'reading','With enough practice, many reading problems are solvable.' UNION ALL
  SELECT 'solvable','adj','speaking','This issue is solvable if we manage time better.' UNION ALL

  SELECT 'unsolved' hw,'adj' pos,'reading','Some mysteries remain unsolved even after years of research.' UNION ALL
  SELECT 'unsolved','adj','speaking','I still have an unsolved problem: I forget words too fast.' UNION ALL

  -- prevention / preventive
  SELECT 'prevention' hw,'n' pos,'reading','Prevention is often easier than treatment.' UNION ALL
  SELECT 'prevention','n','speaking','For prevention of mistakes, I check my answers twice.' UNION ALL

  SELECT 'preventive' hw,'adj' pos,'reading','Preventive measures can reduce the risk of accidents.' UNION ALL
  SELECT 'preventive','adj','speaking','A preventive habit is turning off notifications while studying.' UNION ALL

  -- avoidable / avoidance
  SELECT 'avoidable' hw,'adj' pos,'reading','Many errors are avoidable with careful review.' UNION ALL
  SELECT 'avoidable','adj','speaking','Some stress is avoidable if I sleep earlier.' UNION ALL

  SELECT 'avoidance' hw,'n' pos,'reading','Avoidance of difficult tasks can increase anxiety.' UNION ALL
  SELECT 'avoidance','n','speaking','Avoidance doesn’t help; I need to face my weak points.' UNION ALL

  -- supportive / suggestion
  SELECT 'supportive' hw,'adj' pos,'reading','A supportive environment helps students stay motivated.' UNION ALL
  SELECT 'supportive','adj','speaking','My parents are supportive when I feel pressured.' UNION ALL

  SELECT 'suggestion' hw,'n' pos,'reading','The teacher gave a helpful suggestion for improving pronunciation.' UNION ALL
  SELECT 'suggestion','n','speaking','My suggestion is to practice speaking for one minute daily.' UNION ALL

  -- strategic / strategically
  SELECT 'strategic' hw,'adj' pos,'reading','Strategic planning is important for long-term success.' UNION ALL
  SELECT 'strategic','adj','speaking','I make a strategic choice to study in the morning.' UNION ALL

  SELECT 'strategically' hw,'adv' pos,'reading','Students should use their time strategically during exam season.' UNION ALL
  SELECT 'strategically','adv','speaking','I study strategically by reviewing the most difficult words first.' UNION ALL

  -- risky / beneficial / beneficiary
  SELECT 'risky' hw,'adj' pos,'reading','Skipping sleep to study is risky for your health.' UNION ALL
  SELECT 'risky','adj','speaking','It’s risky to rely only on last-minute 공부.' UNION ALL

  SELECT 'beneficial' hw,'adj' pos,'reading','Regular reading is beneficial for vocabulary growth.' UNION ALL
  SELECT 'beneficial','adj','speaking','It’s beneficial to record myself and check my mistakes.' UNION ALL

  SELECT 'beneficiary' hw,'n' pos,'reading','The beneficiary of the program is the local community.' UNION ALL
  SELECT 'beneficiary','n','speaking','Students are the main beneficiaries of better school policies.' UNION ALL

  -- evident / evidently
  SELECT 'evident' hw,'adj' pos,'reading','It is evident that sleep affects concentration.' UNION ALL
  SELECT 'evident','adj','speaking','It’s evident that practice makes me more confident.' UNION ALL

  SELECT 'evidently' hw,'adv' pos,'reading','Evidently, the new method worked better for most students.' UNION ALL
  SELECT 'evidently','adv','speaking','Evidently, I learn faster when I review consistently.' UNION ALL

  -- argument / conclusion / indication
  SELECT 'argument' hw,'n' pos,'reading','The writer presents an argument supported by evidence.' UNION ALL
  SELECT 'argument','n','speaking','My argument is that school should start later for teens.' UNION ALL

  SELECT 'conclusion' hw,'n' pos,'reading','The conclusion summarizes the main points of the passage.' UNION ALL
  SELECT 'conclusion','n','speaking','My conclusion is that balance is more important than intensity.' UNION ALL

  SELECT 'indication' hw,'n' pos,'reading','A rise in scores is an indication of effective study.' UNION ALL
  SELECT 'indication','n','speaking','This is a clear indication that I need more sleep.' UNION ALL

  -- researcher / database / research-based / data-driven
  SELECT 'researcher' hw,'n' pos,'reading','The researcher collected data from 300 students.' UNION ALL
  SELECT 'researcher','n','speaking','A researcher might test how sleep affects memory.' UNION ALL

  SELECT 'database' hw,'n' pos,'reading','The school stored student results in a database.' UNION ALL
  SELECT 'database','n','speaking','I keep a small database of words I often forget.' UNION ALL

  SELECT 'research-based' hw,'adj' pos,'reading','Research-based methods often outperform guessing strategies.' UNION ALL
  SELECT 'research-based','adj','speaking','I prefer research-based study methods, not random ones.' UNION ALL

  SELECT 'data-driven' hw,'adj' pos,'reading','A data-driven approach can reveal learning patterns.' UNION ALL
  SELECT 'data-driven','adj','speaking','My plan is data-driven: I review what I missed most.' UNION ALL

  -- methodical / practical / improvement / maintenance / focused / revision / consistent / consistently / goal-setting
  SELECT 'methodical' hw,'adj' pos,'reading','A methodical approach helps reduce careless errors.' UNION ALL
  SELECT 'methodical','adj','speaking','I try to be methodical when I review my mistakes.' UNION ALL

  SELECT 'practical' hw,'adj' pos,'reading','Practical advice is easier to follow than abstract theory.' UNION ALL
  SELECT 'practical','adj','speaking','A practical tip is to study in short sessions.' UNION ALL

  SELECT 'improvement' hw,'n' pos,'reading','The report showed significant improvement in reading speed.' UNION ALL
  SELECT 'improvement','n','speaking','I saw improvement after I started daily speaking practice.' UNION ALL

  SELECT 'maintenance' hw,'n' pos,'reading','Regular maintenance keeps the system working properly.' UNION ALL
  SELECT 'maintenance','n','speaking','Vocabulary maintenance is easier with weekly review.' UNION ALL

  SELECT 'focused' hw,'adj' pos,'reading','Focused attention improves comprehension.' UNION ALL
  SELECT 'focused','adj','speaking','I stay focused by turning off notifications.' UNION ALL

  SELECT 'revision' hw,'n' pos,'reading','Revision is necessary before an important test.' UNION ALL
  SELECT 'revision','n','speaking','I do a quick revision of today’s words at night.' UNION ALL

  SELECT 'consistent' hw,'adj' pos,'reading','Consistent practice leads to steady progress.' UNION ALL
  SELECT 'consistent','adj','speaking','I need a consistent routine to keep improving.' UNION ALL

  SELECT 'consistently' hw,'adv' pos,'reading','Students who study consistently perform better.' UNION ALL
  SELECT 'consistently','adv','speaking','I consistently review words for five minutes daily.' UNION ALL

  SELECT 'goal-setting' hw,'n' pos,'reading','Goal-setting increases motivation and direction.' UNION ALL
  SELECT 'goal-setting','n','speaking','Goal-setting helps me stay motivated during exam season.' UNION ALL

  -- comparison / comparative / similarity / difference / differ / preference / optional / balanced / efficiency
  SELECT 'comparison' hw,'n' pos,'reading','In comparison, the second group improved faster.' UNION ALL
  SELECT 'comparison','n','speaking','I made a comparison between morning study and night study.' UNION ALL

  SELECT 'comparative' hw,'adj' pos,'reading','The passage provides a comparative analysis of two systems.' UNION ALL
  SELECT 'comparative','adj','speaking','I wrote a comparative summary of online and offline learning.' UNION ALL

  SELECT 'similarity' hw,'n' pos,'reading','There is a similarity between the two results.' UNION ALL
  SELECT 'similarity','n','speaking','One similarity is that both methods require practice.' UNION ALL

  SELECT 'difference' hw,'n' pos,'reading','There is a clear difference between short-term and long-term memory.' UNION ALL
  SELECT 'difference','n','speaking','The biggest difference is how much focus students need.' UNION ALL

  SELECT 'differ' hw,'v' pos,'reading','Opinions differ among researchers.' UNION ALL
  SELECT 'differ','v','speaking','My view differs from my friend’s view.' UNION ALL

  SELECT 'preference' hw,'n' pos,'reading','Student preference can influence course design.' UNION ALL
  SELECT 'preference','n','speaking','My preference is studying alone because I focus better.' UNION ALL

  SELECT 'optional' hw,'adj' pos,'reading','The extra reading is optional, not required.' UNION ALL
  SELECT 'optional','adj','speaking','Speaking practice is optional in class, but I do it anyway.' UNION ALL

  SELECT 'balanced' hw,'adj' pos,'reading','A balanced schedule includes both study and rest.' UNION ALL
  SELECT 'balanced','adj','speaking','I try to keep a balanced routine during exams.' UNION ALL

  SELECT 'efficiency' hw,'n' pos,'reading','Efficiency improves when students use a clear study plan.' UNION ALL
  SELECT 'efficiency','n','speaking','My efficiency increased after I removed distractions.' UNION ALL

  -- recommendation / decision / motivation / confident / confidently
  SELECT 'recommendation' hw,'n' pos,'reading','The doctor’s recommendation was to sleep more.' UNION ALL
  SELECT 'recommendation','n','speaking','My recommendation is to review words with example sentences.' UNION ALL

  SELECT 'decision' hw,'n' pos,'reading','Good decisions require careful thinking.' UNION ALL
  SELECT 'decision','n','speaking','My decision was to practice speaking every day.' UNION ALL

  SELECT 'motivation' hw,'n' pos,'reading','Motivation often increases when progress is visible.' UNION ALL
  SELECT 'motivation','n','speaking','My motivation rises when I see small improvements.' UNION ALL

  SELECT 'confident' hw,'adj' pos,'reading','Confident speakers make fewer long pauses.' UNION ALL
  SELECT 'confident','adj','speaking','I feel confident when I practice with a clear pattern.' UNION ALL

  SELECT 'confidently' hw,'adv' pos,'reading','She answered confidently during the interview.' UNION ALL
  SELECT 'confidently','adv','speaking','I want to speak confidently in English class.' UNION ALL

  -- agreement / disagreement / limitation / necessity / unnecessary / imbalance / unbalanced
  SELECT 'agreement' hw,'n' pos,'reading','There is agreement that sleep is important for learning.' UNION ALL
  SELECT 'agreement','n','speaking','We reached an agreement about study time.' UNION ALL

  SELECT 'disagreement' hw,'n' pos,'reading','Disagreement often happens when evidence is unclear.' UNION ALL
  SELECT 'disagreement','n','speaking','We had a disagreement, but we listened to each other.' UNION ALL

  SELECT 'limitation' hw,'n' pos,'reading','One limitation of the study is the small sample size.' UNION ALL
  SELECT 'limitation','n','speaking','A limitation is that I don’t have enough time on weekdays.' UNION ALL

  SELECT 'necessity' hw,'n' pos,'reading','Sleep is a necessity for healthy growth.' UNION ALL
  SELECT 'necessity','n','speaking','Daily review is a necessity for me, not a choice.' UNION ALL

  SELECT 'unnecessary' hw,'adj' pos,'reading','Too much homework can create unnecessary stress.' UNION ALL
  SELECT 'unnecessary','adj','speaking','It’s unnecessary to study for five hours without breaks.' UNION ALL

  SELECT 'imbalance' hw,'n' pos,'reading','Imbalance between work and rest can harm health.' UNION ALL
  SELECT 'imbalance','n','speaking','I noticed an imbalance: too much study and too little sleep.' UNION ALL

  SELECT 'unbalanced' hw,'adj' pos,'reading','An unbalanced diet can cause health problems.' UNION ALL
  SELECT 'unbalanced','adj','speaking','My schedule becomes unbalanced during exam week.'
) x ON x.hw=w.headword AND x.pos=w.pos
WHERE w.is_derived=1;


COMMIT;


/* =========================================================
   ✅ 빠른 검증
   ========================================================= */

-- 1) 파생어 정의가 [AUTO]가 아닌지 확인
SELECT headword, pos, cefr, definition_simple
FROM words
WHERE is_derived=1 AND definition_simple LIKE '[AUTO]%'
ORDER BY headword
LIMIT 50;

-- 2) 특정 root의 파생어 카드 + 예문 유무 확인 (예: effect(n))
SELECT
  r.headword AS root, r.pos AS root_pos,
  d.headword AS derived, d.pos AS derived_pos,
  SUM(ex.ex_type='reading') AS has_reading,
  SUM(ex.ex_type='speaking') AS has_speaking
FROM word_family_edges e
JOIN words r ON r.word_id=e.root_word_id
JOIN words d ON d.word_id=e.derived_word_id
LEFT JOIN example_sentences ex ON ex.word_id=d.word_id
WHERE r.headword='effect' AND r.pos='n'
GROUP BY d.word_id
ORDER BY d.headword;