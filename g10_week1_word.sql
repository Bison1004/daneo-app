/* =========================================================
   HS1 Week1 Day1~Day7 FULL INSERT (Synonyms/Collocations/Examples)
   + Day1 10th word fix: impact
   ========================================================= */

-- 0) Day1 누락 10번째 단어 추가: impact
INSERT INTO words (headword, pos, cefr, definition_simple)
VALUES ('impact','n/v','B1','a strong effect or influence; to strongly affect')
ON DUPLICATE KEY UPDATE definition_simple=VALUES(definition_simple);

-- Day1에 impact를 sort_no=10으로 추가
INSERT INTO day_words (day_id, word_id, sort_no)
SELECT d.day_id, w.word_id, 10
FROM days d
JOIN words w ON w.headword='impact' AND w.pos='n/v'
WHERE d.grade='HighSchool_1' AND d.week_no=1 AND d.day_no=1
ON DUPLICATE KEY UPDATE sort_no=VALUES(sort_no);

/* =========================================================
   1) word_synonyms (전 단어)
   ========================================================= */

-- Day1
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  SELECT 'cause' hw,'v/n' pos,'reason' syn,1 lv UNION ALL
  SELECT 'cause','v/n','lead to',1 UNION ALL
  SELECT 'cause','v/n','trigger',2 UNION ALL

  SELECT 'effect','n','result',1 UNION ALL
  SELECT 'effect','n','impact',2 UNION ALL
  SELECT 'effect','n','influence',2 UNION ALL

  SELECT 'affect','v','influence',1 UNION ALL
  SELECT 'affect','v','impact',2 UNION ALL

  SELECT 'result','n/v','outcome',2 UNION ALL
  SELECT 'result','n/v','consequence',3 UNION ALL

  SELECT 'factor','n','element',1 UNION ALL
  SELECT 'factor','n','cause',1 UNION ALL

  SELECT 'increase','v/n','rise',1 UNION ALL
  SELECT 'increase','v/n','grow',1 UNION ALL
  SELECT 'increase','v/n','expand',2 UNION ALL

  SELECT 'reduce','v','decrease',1 UNION ALL
  SELECT 'reduce','v','lower',1 UNION ALL
  SELECT 'reduce','v','cut',1 UNION ALL

  SELECT 'require','v','need',1 UNION ALL
  SELECT 'require','v','demand',2 UNION ALL

  SELECT 'solution','n','answer',1 UNION ALL
  SELECT 'solution','n','resolution',2 UNION ALL

  SELECT 'impact','n/v','influence',1 UNION ALL
  SELECT 'impact','n/v','effect',1 UNION ALL
  SELECT 'impact','n/v','consequence',2
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day2
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  SELECT 'issue' hw,'n' pos,'problem' syn,1 lv UNION ALL
  SELECT 'issue','n','matter',1 UNION ALL

  SELECT 'challenge','n','difficulty',1 UNION ALL
  SELECT 'challenge','n','obstacle',2 UNION ALL

  SELECT 'prevent','v','stop',1 UNION ALL
  SELECT 'prevent','v','avoid',1 UNION ALL

  SELECT 'avoid','v','prevent',1 UNION ALL
  SELECT 'avoid','v','escape',2 UNION ALL

  SELECT 'manage','v','handle',1 UNION ALL
  SELECT 'manage','v','control',2 UNION ALL

  SELECT 'support','v/n','help',1 UNION ALL
  SELECT 'support','v/n','assist',2 UNION ALL

  SELECT 'suggest','v','recommend',1 UNION ALL
  SELECT 'suggest','v','propose',2 UNION ALL

  SELECT 'strategy','n','plan',1 UNION ALL
  SELECT 'strategy','n','approach',2 UNION ALL

  SELECT 'risk','n','danger',1 UNION ALL
  SELECT 'risk','n','threat',2 UNION ALL

  SELECT 'benefit','n/v','advantage',1 UNION ALL
  SELECT 'benefit','n/v','gain',2
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day3
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  SELECT 'evidence' hw,'n' pos,'proof' syn,2 lv UNION ALL
  SELECT 'evidence','n','sign',1 UNION ALL

  SELECT 'claim','n/v','argue',2 UNION ALL
  SELECT 'claim','n/v','state',1 UNION ALL

  SELECT 'argue','v','claim',1 UNION ALL
  SELECT 'argue','v','insist',2 UNION ALL

  SELECT 'support','v/n','back up',1 UNION ALL
  SELECT 'support','v/n','confirm',2 UNION ALL

  SELECT 'conclude','v','decide',1 UNION ALL
  SELECT 'conclude','v','determine',2 UNION ALL

  SELECT 'indicate','v','show',1 UNION ALL
  SELECT 'indicate','v','suggest',1 UNION ALL

  SELECT 'research','n/v','study',1 UNION ALL
  SELECT 'research','n/v','investigation',2 UNION ALL

  SELECT 'data','n','information',1 UNION ALL
  SELECT 'data','n','figures',2 UNION ALL

  SELECT 'trend','n','pattern',1 UNION ALL
  SELECT 'trend','n','tendency',2
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day4
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  SELECT 'process' hw,'n' pos,'method' syn,1 lv UNION ALL
  SELECT 'process','n','procedure',2 UNION ALL

  SELECT 'method','n','way',1 UNION ALL
  SELECT 'method','n','approach',2 UNION ALL

  SELECT 'step','n','stage',2 UNION ALL
  SELECT 'step','n','phase',3 UNION ALL

  SELECT 'practice','n/v','train',2 UNION ALL
  SELECT 'practice','n/v','rehearse',3 UNION ALL

  SELECT 'improve','v','enhance',2 UNION ALL
  SELECT 'improve','v','develop',2 UNION ALL

  SELECT 'maintain','v','keep',1 UNION ALL
  SELECT 'maintain','v','preserve',2 UNION ALL

  SELECT 'focus','v/n','concentrate',2 UNION ALL
  SELECT 'focus','v/n','pay attention',1 UNION ALL

  SELECT 'review','v/n','check',1 UNION ALL
  SELECT 'review','v/n','revise',2 UNION ALL

  SELECT 'consistency','n','regularity',2 UNION ALL
  SELECT 'consistency','n','steadiness',3 UNION ALL

  SELECT 'goal','n','aim',1 UNION ALL
  SELECT 'goal','n','objective',2
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day5
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  SELECT 'compare' hw,'v' pos,'contrast' syn,2 lv UNION ALL
  SELECT 'compare','v','examine',2 UNION ALL

  SELECT 'contrast','v/n','compare',1 UNION ALL
  SELECT 'contrast','v/n','differ',1 UNION ALL

  SELECT 'similar','adj','alike',2 UNION ALL
  SELECT 'similar','adj','close',1 UNION ALL

  SELECT 'different','adj','distinct',3 UNION ALL
  SELECT 'different','adj','not the same',1 UNION ALL

  SELECT 'advantage','n','benefit',1 UNION ALL
  SELECT 'advantage','n','strength',2 UNION ALL

  SELECT 'disadvantage','n','drawback',2 UNION ALL
  SELECT 'disadvantage','n','weakness',2 UNION ALL

  SELECT 'prefer','v','like better',1 UNION ALL
  SELECT 'prefer','v','choose',1 UNION ALL

  SELECT 'option','n','choice',1 UNION ALL
  SELECT 'option','n','alternative',2 UNION ALL

  SELECT 'balance','n/v','stability',2 UNION ALL
  SELECT 'balance','n/v','harmony',3 UNION ALL

  SELECT 'efficient','adj','effective',2 UNION ALL
  SELECT 'efficient','adj','productive',2
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day6
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  SELECT 'opinion' hw,'n' pos,'view' syn,2 lv UNION ALL
  SELECT 'opinion','n','belief',2 UNION ALL

  SELECT 'reason','n','cause',1 UNION ALL
  SELECT 'reason','n','explanation',2 UNION ALL

  SELECT 'example','n','case',2 UNION ALL
  SELECT 'example','n','instance',3 UNION ALL

  SELECT 'explain','v','describe',1 UNION ALL
  SELECT 'explain','v','clarify',2 UNION ALL

  SELECT 'recommend','v','suggest',1 UNION ALL
  SELECT 'recommend','v','advise',2 UNION ALL

  SELECT 'decide','v','choose',1 UNION ALL
  SELECT 'decide','v','determine',2 UNION ALL

  SELECT 'pressure','n','stress',1 UNION ALL
  SELECT 'pressure','n','burden',2 UNION ALL

  SELECT 'motivate','v','encourage',1 UNION ALL
  SELECT 'motivate','v','inspire',2 UNION ALL

  SELECT 'confidence','n','self-belief',2 UNION ALL
  SELECT 'confidence','n','assurance',3 UNION ALL

  SELECT 'habit','n','routine',1 UNION ALL
  SELECT 'habit','n','pattern',2
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day7
INSERT INTO word_synonyms (word_id, synonym_word, nuance_level)
SELECT w.word_id, x.syn, x.lv
FROM words w
JOIN (
  SELECT 'argue' hw,'v' pos,'claim' syn,1 lv UNION ALL
  SELECT 'argue','v','say',1 UNION ALL

  SELECT 'agree','v','accept',2 UNION ALL
  SELECT 'agree','v','support',2 UNION ALL

  SELECT 'disagree','v','oppose',2 UNION ALL
  SELECT 'disagree','v','object',2 UNION ALL

  SELECT 'however','adv','but',1 UNION ALL
  SELECT 'however','adv','nevertheless',3 UNION ALL

  SELECT 'although','conj','even though',2 UNION ALL

  SELECT 'consider','v','think about',1 UNION ALL
  SELECT 'consider','v','take into account',2 UNION ALL

  SELECT 'perspective','n','point of view',1 UNION ALL
  SELECT 'perspective','n','viewpoint',2 UNION ALL

  SELECT 'limit','v/n','restrict',2 UNION ALL
  SELECT 'limit','v/n','reduce',1 UNION ALL

  SELECT 'necessary','adj','required',1 UNION ALL
  SELECT 'necessary','adj','essential',2 UNION ALL

  SELECT 'effective','adj','useful',1 UNION ALL
  SELECT 'effective','adj','efficient',2
) x ON x.hw=w.headword AND x.pos=w.pos;


/* =========================================================
   2) word_collocations (전 단어)
   ========================================================= */

-- Day1
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  SELECT 'cause' hw,'v/n' pos,'cause a problem' col,'high' fb UNION ALL
  SELECT 'cause','v/n','cause stress','high' UNION ALL
  SELECT 'cause','v/n','main cause','high' UNION ALL

  SELECT 'effect','n','have an effect on','high' UNION ALL
  SELECT 'effect','n','positive effect','high' UNION ALL
  SELECT 'effect','n','long-term effect','high' UNION ALL

  SELECT 'affect','v','affect behavior','high' UNION ALL
  SELECT 'affect','v','affect health','high' UNION ALL
  SELECT 'affect','v','directly affect','medium' UNION ALL

  SELECT 'result','n/v','result in','high' UNION ALL
  SELECT 'result','n/v','as a result','high' UNION ALL
  SELECT 'result','n/v','final result','medium' UNION ALL

  SELECT 'factor','n','key factor','high' UNION ALL
  SELECT 'factor','n','major factor','high' UNION ALL
  SELECT 'factor','n','a factor in','high' UNION ALL

  SELECT 'increase','v/n','increase the number','high' UNION ALL
  SELECT 'increase','v/n','sharp increase','high' UNION ALL
  SELECT 'increase','v/n','increase rapidly','medium' UNION ALL

  SELECT 'reduce','v','reduce stress','high' UNION ALL
  SELECT 'reduce','v','reduce costs','high' UNION ALL
  SELECT 'reduce','v','reduce the risk','high' UNION ALL

  SELECT 'require','v','require time','high' UNION ALL
  SELECT 'require','v','require effort','high' UNION ALL
  SELECT 'require','v','be required to','high' UNION ALL

  SELECT 'solution','n','find a solution','high' UNION ALL
  SELECT 'solution','n','practical solution','medium' UNION ALL
  SELECT 'solution','n','a solution to','high' UNION ALL

  SELECT 'impact','n/v','have an impact on','high' UNION ALL
  SELECT 'impact','n/v','significant impact','high' UNION ALL
  SELECT 'impact','n/v','negative impact','high'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day2
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  SELECT 'issue' hw,'n' pos,'social issue' col,'high' fb UNION ALL
  SELECT 'issue','n','serious issue','high' UNION ALL
  SELECT 'issue','n','deal with an issue','medium' UNION ALL

  SELECT 'challenge','n','face a challenge','high' UNION ALL
  SELECT 'challenge','n','major challenge','high' UNION ALL
  SELECT 'challenge','n','meet the challenge','medium' UNION ALL

  SELECT 'prevent','v','prevent disease','high' UNION ALL
  SELECT 'prevent','v','prevent accidents','high' UNION ALL
  SELECT 'prevent','v','prevent (A) from ~ing','high' UNION ALL

  SELECT 'avoid','v','avoid mistakes','high' UNION ALL
  SELECT 'avoid','v','avoid conflict','medium' UNION ALL
  SELECT 'avoid','v','avoid doing','high' UNION ALL

  SELECT 'manage','v','manage time','high' UNION ALL
  SELECT 'manage','v','manage stress','high' UNION ALL
  SELECT 'manage','v','manage a project','medium' UNION ALL

  SELECT 'support','v/n','support a claim','high' UNION ALL
  SELECT 'support','v/n','get support','medium' UNION ALL
  SELECT 'support','v/n','emotional support','medium' UNION ALL

  SELECT 'suggest','v','suggest that','high' UNION ALL
  SELECT 'suggest','v','suggest a plan','medium' UNION ALL
  SELECT 'suggest','v','strongly suggest','medium' UNION ALL

  SELECT 'strategy','n','learning strategy','high' UNION ALL
  SELECT 'strategy','n','effective strategy','high' UNION ALL
  SELECT 'strategy','n','use a strategy','high' UNION ALL

  SELECT 'risk','n','reduce the risk','high' UNION ALL
  SELECT 'risk','n','at risk','high' UNION ALL
  SELECT 'risk','n','high risk','high' UNION ALL

  SELECT 'benefit','n/v','benefit from','high' UNION ALL
  SELECT 'benefit','n/v','health benefits','high' UNION ALL
  SELECT 'benefit','n/v','mutual benefit','medium'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day3
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  SELECT 'evidence' hw,'n' pos,'strong evidence' col,'high' fb UNION ALL
  SELECT 'evidence','n','evidence of','high' UNION ALL
  SELECT 'evidence','n','scientific evidence','medium' UNION ALL

  SELECT 'claim','n/v','make a claim','high' UNION ALL
  SELECT 'claim','n/v','support a claim','high' UNION ALL
  SELECT 'claim','n/v','false claim','medium' UNION ALL

  SELECT 'argue','v','argue that','high' UNION ALL
  SELECT 'argue','v','argue against','high' UNION ALL
  SELECT 'argue','v','strongly argue','medium' UNION ALL

  SELECT 'support','v/n','support with evidence','high' UNION ALL
  SELECT 'support','v/n','support an idea','high' UNION ALL
  SELECT 'support','v/n','support a conclusion','medium' UNION ALL

  SELECT 'conclude','v','conclude that','high' UNION ALL
  SELECT 'conclude','v','reach a conclusion','high' UNION ALL
  SELECT 'conclude','v','final conclusion','medium' UNION ALL

  SELECT 'indicate','v','indicate that','high' UNION ALL
  SELECT 'indicate','v','clear indication','medium' UNION ALL
  SELECT 'indicate','v','results indicate','high' UNION ALL

  SELECT 'research','n/v','do research','high' UNION ALL
  SELECT 'research','n/v','research shows','high' UNION ALL
  SELECT 'research','n/v','research findings','medium' UNION ALL

  SELECT 'data','n','collect data','high' UNION ALL
  SELECT 'data','n','analyze data','high' UNION ALL
  SELECT 'data','n','data shows','high' UNION ALL

  SELECT 'trend','n','a growing trend','high' UNION ALL
  SELECT 'trend','n','trend toward','high' UNION ALL
  SELECT 'trend','n','follow a trend','medium'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day4
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  SELECT 'process' hw,'n' pos,'learning process' col,'high' fb UNION ALL
  SELECT 'process','n','in the process of','high' UNION ALL
  SELECT 'process','n','a slow process','medium' UNION ALL

  SELECT 'method','n','effective method','high' UNION ALL
  SELECT 'method','n','teaching method','high' UNION ALL
  SELECT 'method','n','use a method','high' UNION ALL

  SELECT 'step','n','first step','high' UNION ALL
  SELECT 'step','n','next step','high' UNION ALL
  SELECT 'step','n','take steps to','high' UNION ALL

  SELECT 'practice','n/v','practice speaking','high' UNION ALL
  SELECT 'practice','n/v','daily practice','high' UNION ALL
  SELECT 'practice','n/v','practice makes perfect','medium' UNION ALL

  SELECT 'improve','v','improve skills','high' UNION ALL
  SELECT 'improve','v','improve performance','high' UNION ALL
  SELECT 'improve','v','greatly improve','medium' UNION ALL

  SELECT 'maintain','v','maintain health','medium' UNION ALL
  SELECT 'maintain','v','maintain a habit','high' UNION ALL
  SELECT 'maintain','v','maintain quality','medium' UNION ALL

  SELECT 'focus','v/n','focus on','high' UNION ALL
  SELECT 'focus','v/n','stay focused','high' UNION ALL
  SELECT 'focus','v/n','main focus','medium' UNION ALL

  SELECT 'review','v/n','review notes','high' UNION ALL
  SELECT 'review','v/n','weekly review','high' UNION ALL
  SELECT 'review','v/n','review for a test','medium' UNION ALL

  SELECT 'consistency','n','build consistency','medium' UNION ALL
  SELECT 'consistency','n','consistent effort','high' UNION ALL
  SELECT 'consistency','n','practice consistently','high' UNION ALL

  SELECT 'goal','n','set a goal','high' UNION ALL
  SELECT 'goal','n','reach a goal','high' UNION ALL
  SELECT 'goal','n','long-term goal','medium'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day5
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  SELECT 'compare' hw,'v' pos,'compare A and B' col,'high' fb UNION ALL
  SELECT 'compare','v','compared to','high' UNION ALL
  SELECT 'compare','v','compare with','high' UNION ALL

  SELECT 'contrast','v/n','in contrast','high' UNION ALL
  SELECT 'contrast','v/n','contrast with','high' UNION ALL
  SELECT 'contrast','v/n','sharp contrast','medium' UNION ALL

  SELECT 'similar','adj','similar to','high' UNION ALL
  SELECT 'similar','adj','very similar','medium' UNION ALL
  SELECT 'similar','adj','in a similar way','medium' UNION ALL

  SELECT 'different','adj','different from','high' UNION ALL
  SELECT 'different','adj','completely different','high' UNION ALL
  SELECT 'different','adj','a big difference','high' UNION ALL

  SELECT 'advantage','n','an advantage of','high' UNION ALL
  SELECT 'advantage','n','main advantage','high' UNION ALL
  SELECT 'advantage','n','take advantage of','high' UNION ALL

  SELECT 'disadvantage','n','a disadvantage of','high' UNION ALL
  SELECT 'disadvantage','n','main disadvantage','high' UNION ALL
  SELECT 'disadvantage','n','serious disadvantage','medium' UNION ALL

  SELECT 'prefer','v','prefer A to B','high' UNION ALL
  SELECT 'prefer','v','prefer to do','high' UNION ALL
  SELECT 'prefer','v','personal preference','medium' UNION ALL

  SELECT 'option','n','a good option','high' UNION ALL
  SELECT 'option','n','choose an option','high' UNION ALL
  SELECT 'option','n','have the option to','high' UNION ALL

  SELECT 'balance','n/v','keep a balance','high' UNION ALL
  SELECT 'balance','n/v','work-life balance','medium' UNION ALL
  SELECT 'balance','n/v','balance A and B','high' UNION ALL

  SELECT 'efficient','adj','an efficient way','high' UNION ALL
  SELECT 'efficient','adj','work efficiently','high' UNION ALL
  SELECT 'efficient','adj','time-efficient','medium'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day6
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  SELECT 'opinion' hw,'n' pos,'in my opinion' col,'high' fb UNION ALL
  SELECT 'opinion','n','public opinion','medium' UNION ALL
  SELECT 'opinion','n','share an opinion','medium' UNION ALL

  SELECT 'reason','n','main reason','high' UNION ALL
  SELECT 'reason','n','for this reason','high' UNION ALL
  SELECT 'reason','n','a reason why','high' UNION ALL

  SELECT 'example','n','give an example','high' UNION ALL
  SELECT 'example','n','for example','high' UNION ALL
  SELECT 'example','n','real-life example','medium' UNION ALL

  SELECT 'explain','v','explain why','high' UNION ALL
  SELECT 'explain','v','explain clearly','medium' UNION ALL
  SELECT 'explain','v','explain the reason','medium' UNION ALL

  SELECT 'recommend','v','recommend that','high' UNION ALL
  SELECT 'recommend','v','highly recommend','medium' UNION ALL
  SELECT 'recommend','v','recommend a method','medium' UNION ALL

  SELECT 'decide','v','make a decision','high' UNION ALL
  SELECT 'decide','v','decide to','high' UNION ALL
  SELECT 'decide','v','hard decision','medium' UNION ALL

  SELECT 'pressure','n','feel pressure','high' UNION ALL
  SELECT 'pressure','n','under pressure','high' UNION ALL
  SELECT 'pressure','n','peer pressure','medium' UNION ALL

  SELECT 'motivate','v','motivate students','medium' UNION ALL
  SELECT 'motivate','v','stay motivated','high' UNION ALL
  SELECT 'motivate','v','motivation to','medium' UNION ALL

  SELECT 'confidence','n','build confidence','high' UNION ALL
  SELECT 'confidence','n','lack confidence','medium' UNION ALL
  SELECT 'confidence','n','gain confidence','high' UNION ALL

  SELECT 'habit','n','good habit','high' UNION ALL
  SELECT 'habit','n','bad habit','high' UNION ALL
  SELECT 'habit','n','form a habit','high'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day7
INSERT INTO word_collocations (word_id, collocation, freq_band)
SELECT w.word_id, x.col, x.fb
FROM words w
JOIN (
  SELECT 'argue' hw,'v' pos,'argue that' col,'high' fb UNION ALL
  SELECT 'argue','v','argue against','high' UNION ALL
  SELECT 'argue','v','argue for','high' UNION ALL

  SELECT 'agree','v','agree with','high' UNION ALL
  SELECT 'agree','v','agree that','high' UNION ALL
  SELECT 'agree','v','completely agree','medium' UNION ALL

  SELECT 'disagree','v','disagree with','high' UNION ALL
  SELECT 'disagree','v','strongly disagree','medium' UNION ALL
  SELECT 'disagree','v','disagree about','medium' UNION ALL

  SELECT 'however','adv','however, + clause','high' UNION ALL
  SELECT 'however','adv','however + adj/adv','medium' UNION ALL

  SELECT 'although','conj','although + clause','high' UNION ALL
  SELECT 'although','conj','although it is true','medium' UNION ALL

  SELECT 'consider','v','consider + noun','high' UNION ALL
  SELECT 'consider','v','consider doing','high' UNION ALL
  SELECT 'consider','v','take into consideration','medium' UNION ALL

  SELECT 'perspective','n','from a perspective','medium' UNION ALL
  SELECT 'perspective','n','different perspectives','high' UNION ALL
  SELECT 'perspective','n','broaden perspective','medium' UNION ALL

  SELECT 'limit','v/n','set a limit','high' UNION ALL
  SELECT 'limit','v/n','limit screen time','high' UNION ALL
  SELECT 'limit','v/n','within limits','medium' UNION ALL

  SELECT 'necessary','adj','it is necessary to','high' UNION ALL
  SELECT 'necessary','adj','absolutely necessary','medium' UNION ALL
  SELECT 'necessary','adj','necessary for','high' UNION ALL

  SELECT 'effective','adj','effective way','high' UNION ALL
  SELECT 'effective','adj','highly effective','medium' UNION ALL
  SELECT 'effective','adj','effective for','medium'
) x ON x.hw=w.headword AND x.pos=w.pos;


/* =========================================================
   3) example_sentences (전 단어: reading 1 + speaking 1)
   ========================================================= */

-- Day1 examples
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  SELECT 'cause' hw,'v/n' pos,'reading' ex_type,'Lack of sleep can cause serious health problems.' sentence UNION ALL
  SELECT 'cause','v/n','speaking','Too much homework causes stress for many students.' UNION ALL

  SELECT 'effect','n','reading','Social media can have an effect on teenagers\' self-esteem.' UNION ALL
  SELECT 'effect','n','speaking','Exercise has a positive effect on my mood.' UNION ALL

  SELECT 'affect','v','reading','Weather can affect how people feel and behave.' UNION ALL
  SELECT 'affect','v','speaking','Noise affects my concentration when I study.' UNION ALL

  SELECT 'result','n/v','reading','Poor planning often results in failure.' UNION ALL
  SELECT 'result','n/v','speaking','As a result, students feel less motivated.' UNION ALL

  SELECT 'factor','n','reading','Cost is a major factor in choosing a school.' UNION ALL
  SELECT 'factor','n','speaking','One key factor is how much time students have.' UNION ALL

  SELECT 'increase','v/n','reading','The number of online classes increased during the pandemic.' UNION ALL
  SELECT 'increase','v/n','speaking','I try to increase my study time little by little.' UNION ALL

  SELECT 'reduce','v','reading','Regular exercise can reduce the risk of disease.' UNION ALL
  SELECT 'reduce','v','speaking','To reduce stress, I take short breaks.' UNION ALL

  SELECT 'require','v','reading','Most jobs require good communication skills.' UNION ALL
  SELECT 'require','v','speaking','Success requires effort every day.' UNION ALL

  SELECT 'solution','n','reading','Scientists are looking for a solution to plastic pollution.' UNION ALL
  SELECT 'solution','n','speaking','One practical solution is to study in short sessions.' UNION ALL

  SELECT 'impact','n/v','reading','Smartphones can have a significant impact on learning.' UNION ALL
  SELECT 'impact','n/v','speaking','Phone use impacts my focus when I study.'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day2 examples
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  SELECT 'issue' hw,'n' pos,'reading','Bullying is a serious issue in some schools.' sentence UNION ALL
  SELECT 'issue','n','speaking','One issue is that students don\'t get enough sleep.' UNION ALL

  SELECT 'challenge','n','reading','Adapting to a new school can be challenging.' UNION ALL
  SELECT 'challenge','n','speaking','Time management is my biggest challenge.' UNION ALL

  SELECT 'prevent','v','reading','Wearing a seatbelt helps prevent injuries.' UNION ALL
  SELECT 'prevent','v','speaking','I turn off my phone to prevent distractions.' UNION ALL

  SELECT 'avoid','v','reading','To avoid mistakes, check your work twice.' UNION ALL
  SELECT 'avoid','v','speaking','I avoid studying late at night.' UNION ALL

  SELECT 'manage','v','reading','Good students manage their time well.' UNION ALL
  SELECT 'manage','v','speaking','I try to manage stress by exercising.' UNION ALL

  SELECT 'support','v/n','reading','Strong evidence supports the scientist\'s claim.' UNION ALL
  SELECT 'support','v/n','speaking','My family supports me when I feel tired.' UNION ALL

  SELECT 'suggest','v','reading','The report suggests that students sleep more.' UNION ALL
  SELECT 'suggest','v','speaking','I suggest studying for 30 minutes and resting.' UNION ALL

  SELECT 'strategy','n','reading','A good strategy can improve reading speed.' UNION ALL
  SELECT 'strategy','n','speaking','My strategy is to review words every morning.' UNION ALL

  SELECT 'risk','n','reading','Smoking increases the risk of disease.' UNION ALL
  SELECT 'risk','n','speaking','Using my phone late increases the risk of poor sleep.' UNION ALL

  SELECT 'benefit','n/v','reading','Students benefit from regular feedback.' UNION ALL
  SELECT 'benefit','n/v','speaking','Reading daily benefits my vocabulary.'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day3 examples
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  SELECT 'evidence' hw,'n' pos,'reading','There is strong evidence that exercise improves memory.' sentence UNION ALL
  SELECT 'evidence','n','speaking','I have evidence because my scores improved after practice.' UNION ALL

  SELECT 'claim','n/v','reading','The article claims that teens need more sleep.' UNION ALL
  SELECT 'claim','n/v','speaking','Some people claim phones help learning, but it depends.' UNION ALL

  SELECT 'argue','v','reading','Many researchers argue that reading builds empathy.' UNION ALL
  SELECT 'argue','v','speaking','I argue that school should start later.' UNION ALL

  SELECT 'support','v/n','reading','The graph supports the writer\'s conclusion.' UNION ALL
  SELECT 'support','v/n','speaking','I can support my opinion with an example.' UNION ALL

  SELECT 'conclude','v','reading','The study concludes that short naps can help learning.' UNION ALL
  SELECT 'conclude','v','speaking','So I conclude that balance is important.' UNION ALL

  SELECT 'indicate','v','reading','The results indicate that stress lowers performance.' UNION ALL
  SELECT 'indicate','v','speaking','This indicates we need a better schedule.' UNION ALL

  SELECT 'research','n/v','reading','Research shows that sleep affects memory.' UNION ALL
  SELECT 'research','n/v','speaking','I read research that supports this idea.' UNION ALL

  SELECT 'data','n','reading','The scientist collected data from 300 students.' UNION ALL
  SELECT 'data','n','speaking','The data shows a clear trend.' UNION ALL

  SELECT 'trend','n','reading','There is a growing trend toward online learning.' UNION ALL
  SELECT 'trend','n','speaking','I notice a trend: students rely on short videos.'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day4 examples
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  SELECT 'process' hw,'n' pos,'reading','Language learning is a long process.' sentence UNION ALL
  SELECT 'process','n','speaking','My study process has three steps.' UNION ALL

  SELECT 'method','n','reading','The teacher used an effective method to teach reading.' UNION ALL
  SELECT 'method','n','speaking','One method is to review words with sentences.' UNION ALL

  SELECT 'step','n','reading','The first step is to understand the question.' UNION ALL
  SELECT 'step','n','speaking','My next step is to practice speaking.' UNION ALL

  SELECT 'practice','n/v','reading','Regular practice improves fluency.' UNION ALL
  SELECT 'practice','n/v','speaking','I practice speaking for five minutes every day.' UNION ALL

  SELECT 'improve','v','reading','Reading daily can improve vocabulary.' UNION ALL
  SELECT 'improve','v','speaking','I want to improve my speaking confidence.' UNION ALL

  SELECT 'maintain','v','reading','It is hard to maintain good habits during exams.' UNION ALL
  SELECT 'maintain','v','speaking','I maintain my routine even when I\'m busy.' UNION ALL

  SELECT 'focus','v/n','reading','Students should focus on key ideas in a passage.' UNION ALL
  SELECT 'focus','v/n','speaking','I focus on collocations, not single words.' UNION ALL

  SELECT 'review','v/n','reading','A quick review helps long-term memory.' UNION ALL
  SELECT 'review','v/n','speaking','I review today\'s words before I sleep.' UNION ALL

  SELECT 'consistency','n','reading','Consistency matters more than intensity in learning.' UNION ALL
  SELECT 'consistency','n','speaking','Consistency is the key to improving English.' UNION ALL

  SELECT 'goal','n','reading','Setting a clear goal increases motivation.' UNION ALL
  SELECT 'goal','n','speaking','My goal is to speak for one minute without stopping.'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day5 examples
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  SELECT 'compare' hw,'v' pos,'reading','Compared to print books, e-books are easier to carry.' sentence UNION ALL
  SELECT 'compare','v','speaking','I compared my results before and after practice.' UNION ALL

  SELECT 'contrast','v/n','reading','In contrast, the second group improved faster.' UNION ALL
  SELECT 'contrast','v/n','speaking','In contrast to last year, I feel more confident.' UNION ALL

  SELECT 'similar','adj','reading','Their opinions are similar in many ways.' UNION ALL
  SELECT 'similar','adj','speaking','My routine is similar to my friend\'s routine.' UNION ALL

  SELECT 'different','adj','reading','There is a big difference between short-term and long-term memory.' UNION ALL
  SELECT 'different','adj','speaking','It\'s different from what I expected.' UNION ALL

  SELECT 'advantage','n','reading','One advantage of online learning is flexibility.' UNION ALL
  SELECT 'advantage','n','speaking','The main advantage is that I can study anywhere.' UNION ALL

  SELECT 'disadvantage','n','reading','A disadvantage is that students may lose focus.' UNION ALL
  SELECT 'disadvantage','n','speaking','One drawback is that it\'s easy to get distracted.' UNION ALL

  SELECT 'prefer','v','reading','Some students prefer studying alone.' UNION ALL
  SELECT 'prefer','v','speaking','I prefer reading to watching short videos.' UNION ALL

  SELECT 'option','n','reading','Students have the option to take online classes.' UNION ALL
  SELECT 'option','n','speaking','A good option is to study in the morning.' UNION ALL

  SELECT 'balance','n/v','reading','A balance between study and rest improves performance.' UNION ALL
  SELECT 'balance','n/v','speaking','I try to balance homework and sleep.' UNION ALL

  SELECT 'efficient','adj','reading','Spaced repetition is an efficient way to learn words.' UNION ALL
  SELECT 'efficient','adj','speaking','This method is efficient because it saves time.'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day6 examples
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  SELECT 'opinion' hw,'n' pos,'reading','Public opinion can influence policy.' sentence UNION ALL
  SELECT 'opinion','n','speaking','In my opinion, schools should start later.' UNION ALL

  SELECT 'reason','n','reading','One reason is that teens need more sleep.' UNION ALL
  SELECT 'reason','n','speaking','The main reason is that students are tired.' UNION ALL

  SELECT 'example','n','reading','For example, short breaks can improve focus.' UNION ALL
  SELECT 'example','n','speaking','Let me give an example from my experience.' UNION ALL

  SELECT 'explain','v','reading','The author explains why habits are hard to change.' UNION ALL
  SELECT 'explain','v','speaking','I will explain why this is beneficial.' UNION ALL

  SELECT 'recommend','v','reading','Experts recommend that teens sleep at least eight hours.' UNION ALL
  SELECT 'recommend','v','speaking','I recommend studying with spaced repetition.' UNION ALL

  SELECT 'decide','v','reading','People make decisions faster under pressure.' UNION ALL
  SELECT 'decide','v','speaking','I decided to study in the morning.' UNION ALL

  SELECT 'pressure','n','reading','Students often feel pressure before exams.' UNION ALL
  SELECT 'pressure','n','speaking','Under pressure, I sometimes forget easy words.' UNION ALL

  SELECT 'motivate','v','reading','Clear goals can motivate learners.' UNION ALL
  SELECT 'motivate','v','speaking','A small success motivates me to continue.' UNION ALL

  SELECT 'confidence','n','reading','Practice helps students build confidence.' UNION ALL
  SELECT 'confidence','n','speaking','Recording myself helped me gain confidence.' UNION ALL

  SELECT 'habit','n','reading','A good habit is more powerful than motivation.' UNION ALL
  SELECT 'habit','n','speaking','I\'m trying to form a habit of daily review.'
) x ON x.hw=w.headword AND x.pos=w.pos;

-- Day7 examples
INSERT INTO example_sentences (word_id, ex_type, sentence)
SELECT w.word_id, x.ex_type, x.sentence
FROM words w
JOIN (
  SELECT 'argue' hw,'v' pos,'reading','Some people argue that homework is necessary.' sentence UNION ALL
  SELECT 'argue','v','speaking','I argue that less homework can be more effective.' UNION ALL

  SELECT 'agree','v','reading','Many students agree that sleep is important.' UNION ALL
  SELECT 'agree','v','speaking','I agree that rest matters, but balance is needed.' UNION ALL

  SELECT 'disagree','v','reading','Experts sometimes disagree about the best method.' UNION ALL
  SELECT 'disagree','v','speaking','I disagree because the evidence is weak.' UNION ALL

  SELECT 'however','adv','reading','The idea sounds good; however, it is expensive.' UNION ALL
  SELECT 'however','adv','speaking','However, phones can also be useful for learning.' UNION ALL

  SELECT 'although','conj','reading','Although the method is simple, it is effective.' UNION ALL
  SELECT 'although','conj','speaking','Although I like videos, I prefer reading for deep learning.' UNION ALL

  SELECT 'consider','v','reading','We should consider both costs and benefits.' UNION ALL
  SELECT 'consider','v','speaking','We must consider students\' mental health.' UNION ALL

  SELECT 'perspective','n','reading','From a cultural perspective, the rule may seem strict.' UNION ALL
  SELECT 'perspective','n','speaking','From my perspective, quality matters more than quantity.' UNION ALL

  SELECT 'limit','v/n','reading','Many schools limit phone use during class.' UNION ALL
  SELECT 'limit','v/n','speaking','We should set a limit on screen time.' UNION ALL

  SELECT 'necessary','adj','reading','It is necessary to get enough sleep for learning.' UNION ALL
  SELECT 'necessary','adj','speaking','I think it is necessary to practice speaking daily.' UNION ALL

  SELECT 'effective','adj','reading','Spaced repetition is an effective way to remember words.' UNION ALL
  SELECT 'effective','adj','speaking','This is effective because it forces me to use the words.'
) x ON x.hw=w.headword AND x.pos=w.pos;


/* =========================================================
   (선택) 중복 방지 팁:
   - 이미 넣은 상태에서 재실행할 경우 중복이 생길 수 있음.
   - 운영에서는 (word_id, synonym_word) 등에 UNIQUE를 두는 것을 추천.
   ========================================================= */