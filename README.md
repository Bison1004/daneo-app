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
```

## DB 준비

기본 스키마를 먼저 적용하세요.

```bash
# 예시
mysql -u <user> -p <db_name> < schema.sql
```

필요 시 학습 데이터 SQL 파일(`g10_*.sql`)도 순서에 맞게 적용하세요.

## 실행

```bash
npm start
```

실행 후 브라우저에서 아래 주소를 엽니다.

- http://localhost:3000

## 주요 API

- `GET /api/health` : 서버/DB 헬스체크
- `GET /api/day?grade=HighSchool_1&week=1&day=1` : Day 학습세트 조회
- `GET /api/card?word_id=123` 또는 `GET /api/card?headword=effective&pos=adj` : 단어 카드 조회
- `POST /api/student` : 학생 생성/업데이트
- `POST /api/attempt` : 말하기 시도 저장

## 저장소

- GitHub: https://github.com/Bison1004/daneo-app
