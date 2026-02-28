# CEFR/ACTFL 기반 EFL 365 단어집 운영 가이드

## 1) 목표
- 하루 10단어 × 365일 = 총 3,650개 학습 단위
- 학습자 대상: EFL(중고등~성인 초중급)
- 레벨 축: CEFR + ACTFL 동시 관리

## 2) 단어 선정 6규칙(고정)
아래 6개를 통과한 단어만 채택합니다.

1. 빈도/범용성: 일상·학교·시험·콘텐츠에서 자주 만나는가
2. 기능성(utility): 말/글로 바로 쓰기 쉬운가(동사·형용사 우선)
3. 의미 핵심(core meaning): 핵심 1~2 의미 중심인가
4. 결합력(collocation): 함께 붙는 표현이 선명한가
5. 확장성(word family): 파생어 확장 학습이 가능한가
6. 혼동 위험: 유사어를 같은 날/주에 과밀 배치하지 않았는가

## 3) 카드 필드 표준
### 필수
- Headword
- IPA (US/UK 중 1개 고정 또는 2개 병기)
- Part of Speech
- Derivatives
- Example sentence

### 강력 추천
- Korean gloss (핵심 뜻 1~2개)
- Collocation 1개
- CEFR tag / ACTFL tag

## 4) DB 적용 파일
- 스키마 + 샘플 Day1: cefr_actfl_365_wordbook.sql
- 핵심 조회 뷰: v_wb_day_cards
- 품질 요약 뷰: v_wb_day_quality_summary

## 5) 운영 순서(실무)
1. wb_tracks에 코스(예: HighSchool_1_365_Bridge) 생성
2. wb_days에 day_no 1~365 생성
3. wb_lexemes에 단어/발음/품사/핵심뜻/레벨 입력
4. wb_derivatives, wb_collocations, wb_examples 입력
5. wb_day_items에 day별 10개 배치
6. wb_day_item_rule_checks에 6규칙 통과 여부 기록
7. v_wb_day_cards로 앱 제공 데이터 확인

## 6) 품질 점검 SQL
- day별 10단어 미충족 점검
- 혼동어쌍 동시 배치 점검
- 규칙 통과율 집계 점검

(쿼리 템플릿은 cefr_actfl_365_wordbook.sql 하단 주석 블록 참고)

## 7) Day 2~30 템플릿 빠른 생성
- 명령: `npm run wordbook:template -- 2 30`
- 출력:
	- `wordbook_templates/day_plan_2_30.csv`
	- `wordbook_templates/day_items_2_30.csv`
- `day_items` 파일은 하루 10행(정렬번호 1~10)으로 생성되며,
	단어/발음/뜻/연어/예문/파생어/6규칙 통과여부만 채우면 됩니다.

## 8) CSV를 MySQL로 적재
- 사전 검증: `npm run wordbook:validate`
- 엄격 검증: `npm run wordbook:validate:strict`
- 기본 경로 import: `npm run wordbook:import`
- 경로 지정 import:
	- `node scripts/import_wordbook_csv.js ./wordbook_templates/day_plan_2_30.csv ./wordbook_templates/day_items_2_30.csv`
- validate 스크립트 체크 항목
	- day_no/sort_no 범위
	- day_plan/day_items 연결 무결성
	- day 내 sort_no 중복
	- utility_priority/rule pass-fail 형식
	- core meaning/collocation/example 누락 경고
- strict 모드 추가 체크
	- `core_meaning_en`, `collocation_1`, `example_sentence_1` 누락 시 에러
	- `ipa_us`와 `ipa_uk`가 모두 비면 에러
	- day별 단어 수가 10개가 아니면 에러
- import 스크립트 동작
	- day_plan/day_items를 읽어 track/day/lexeme/day_item을 upsert
	- collocation/example/derivatives upsert
	- 6규칙 체크 결과를 `wb_day_item_rule_checks`에 upsert
	- confusion_pair_word가 채워진 경우 `wb_confusing_pairs` upsert
