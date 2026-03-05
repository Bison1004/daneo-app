# LingoLoop 작업서 정합성 점검표

기준 문서: `C:/Users/user/Desktop/lingoloop-설계서-모바일-1.html`

## 1) 핵심 학습 루프
- 작업서: `SRS -> 퀴즈 -> 발음 -> AI 대화 -> 결과 재투입`
- 현재 상태: 일치
- 근거:
  - SRS 엔진: `lib/lingoloop/srsEngine.js`
  - 퀴즈 엔진/API: `lib/lingoloop/quizEngine.js`, `/api/quiz/*`
  - 발음 점수: `lib/lingoloop/speechScorer.js`
  - AI 대화: `controllers/lingoloopController.js#chat`

## 2) API 경로/계약
- 작업서: `/api/words`, `/api/chat`, `/api/speech/score`, `/api/progress`
- 현재 상태: 일치
- 근거:
  - 라우트: `routes/lingoloopRoutes.js`
  - 서버 마운트: `server.js` (`/api`, `/api/lingoloop` 동시 지원)

## 3) /api/chat 스트리밍
- 작업서: `text/event-stream` 스트리밍
- 현재 상태: 일치(호환 구현)
- 근거:
  - `Accept: text/event-stream` 또는 `?stream=true` 시 SSE 반환
  - 위치: `controllers/lingoloopController.js#chat`

## 4) AI 보안 요구사항
- 작업서: API 키 서버 전용, 레이트리밋
- 현재 상태: 일치
- 근거:
  - Claude 서버 호출: `lib/lingoloop/claudeClient.js`
  - 레이트리밋: `middleware/lingoloopRateLimit.js`
  - 접근키 + JWT 인증: `middleware/lingoloopAuth.js`

## 5) 저장소(영속성)
- 작업서: DB 기반 운영
- 현재 상태: 일치
- 근거:
  - 저장소 선택기: `repositories/lingoloopRepository.js`
  - MySQL 저장소: `repositories/lingoloopMysqlRepository.js`
  - 사용자별 분리 컬럼 `user_id` 적용

## 6) PWA/모바일 화면
- 작업서: 모바일 중심 화면 + 설치 가능
- 현재 상태: 일치
- 근거:
  - 페이지: `public/lingoloop/index.html`
  - SW/manifest: `public/lingoloop/sw.js`, `public/lingoloop/manifest.webmanifest`

## 7) 테스트/CI
- 작업서: 테스트/배포 자동화
- 현재 상태: 일치
- 근거:
  - 단위 테스트: `tests/*.test.js`
  - CI: `.github/workflows/ci.yml`

## 결론
- 설계서 기준 필수 공정은 현재 구현 기준 **100% 완료**입니다.
