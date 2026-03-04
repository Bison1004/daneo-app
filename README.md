# 단어앱 (daneo-app)

EFL 단어 학습용 MVP입니다.  
Node.js(Express) + MySQL + 정적 HTML(`public/index.html`)로 구성되어 있습니다.

## 요구사항

- Node.js 18+
- MySQL 8+

## 설치

```bash
npm install
```

## 환경변수 설정

프로젝트 루트에 `.env` 파일을 만들고 아래 값을 설정하세요.

```env
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=your_database
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin1234
```

## DB 준비

기본 스키마를 먼저 적용하세요.

```bash
# 예시
mysql -u <user> -p <db_name> < schema.sql
mysql -u <user> -p <db_name> < students_table.sql
# CEFR/ACTFL 365일 단어집 확장(선택)
mysql -u <user> -p <db_name> < cefr_actfl_365_wordbook.sql
```

### 로컬 MySQL 빠른 설정(권장)

로컬에서 계정/권한 이슈가 있으면 아래 스크립트를 먼저 실행하세요.

```bash
mysql -u root -p < mysql_local_setup.sql
```

Windows PowerShell에서는 아래 명령을 사용하세요.

```powershell
Get-Content .\mysql_local_setup.sql | mysql -u root -p
```

### AWS RDS SSH 터널 접속(키페어 사용)

키페어 파일이 프로젝트에 있을 때(예: `maru-ec2-seoul-main.pem`) 아래 스크립트로 터널을 열 수 있습니다.

1) `.env`를 터널 모드로 변경

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\use-rds-tunnel-env.ps1
```

2) SSH 터널 시작 (EC2 퍼블릭 DNS/퍼블릭 IP 입력)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-rds-tunnel.ps1 -Ec2Host ec2-xx-xx-xx-xx.ap-northeast-2.compute.amazonaws.com
```

- 기본 포워딩: `127.0.0.1:3307 -> efl-db.czmumoegmwa5.ap-northeast-2.rds.amazonaws.com:3306`
- 터널 터미널은 앱 실행 동안 계속 열어두세요.

그 다음 `.env`를 아래처럼 맞춥니다.

```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=admin
DB_PASSWORD=admin1234!
DB_NAME=efl_vocab_app
```

필요 시 학습 데이터 SQL 파일(`g10_*.sql`)도 순서에 맞게 적용하세요.

## 실행

```bash
npm start
```

실행 후 브라우저에서 아래 주소를 엽니다.

- http://localhost:3000

### 트러블슈팅: /api/health가 500일 때

- `.env` 파일의 `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`를 실제 MySQL 값으로 채우세요.
- 템플릿 값(`your_mysql_user`, `your_database_name`)이 남아 있으면 DB API가 동작하지 않습니다.
- 값 변경 후 서버를 재시작하세요.

## 주요 API

- `GET /api/health` : 서버/DB 헬스체크
- `GET /api/day?grade=HighSchool_1&week=1&day=1` : Day 학습세트 조회
- `GET /api/card?word_id=123` 또는 `GET /api/card?headword=effective&pos=adj` : 단어 카드 조회
- `POST /api/student` : 학생 키 확인(활성 학생 검증)
- `POST /api/attempt` : 말하기 시도 저장

## 관리자 학생관리

- 관리자 페이지(인증 필요)
	- `GET /admin/students` : 학생 목록/검색/상태변경
	- `GET /admin/students/new` : 학생 등록/수정
- 관리자 API(인증 필요)
	- `POST /api/admin/students`
	- `GET /api/admin/students`
	- `GET /api/admin/students/:id`
	- `PUT /api/admin/students/:id`
	- `PATCH /api/admin/students/:id/status`
- 학생 키 검증 API
	- `POST /api/student/verify-key`

## CEFR/ACTFL 365 단어집 확장

- 확장 스키마/샘플 SQL: `cefr_actfl_365_wordbook.sql`
- 운영 기준 문서: `WORDBOOK_365_GUIDE.md`
- 템플릿 자동생성: `npm run wordbook:template -- 2 30`
- CSV 검증(기본 경로): `npm run wordbook:validate`
- CSV 검증(strict): `npm run wordbook:validate:strict`
- CSV 적재(기본 경로): `npm run wordbook:import`
- CSV 적재(경로 지정): `node scripts/import_wordbook_csv.js ./wordbook_templates/day_plan_2_30.csv ./wordbook_templates/day_items_2_30.csv`
- 생성 파일:
	- `wordbook_templates/day_plan_2_30.csv`
	- `wordbook_templates/day_items_2_30.csv`
- 포함 내용:
	- 365일 × 10단어 편성 테이블
	- 카드 필드(단어/IPA/품사/파생어/예문 + 한국어핵심뜻/연어/레벨)
	- 단어 선정 6규칙(빈도/기능성/핵심의미/결합력/확장성/혼동위험) 검증 구조
	- Day 1 샘플 10단어 데이터

권장 순서: 템플릿 생성 → CSV 작성 → `wordbook:validate` → `wordbook:validate:strict` → `wordbook:import`

## 저장소

- GitHub: https://github.com/Bison1004/daneo-app
