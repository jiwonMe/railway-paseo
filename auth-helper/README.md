# Auth Helper

간단한 안내 페이지입니다. Railway에서 에이전트 인증 방법을 안내합니다.

## 사용법

1. 배포 후 `https://your-domain/auth-helper/` 로 접근 (또는 파일을 직접 열기)
2. 안내에 따라 Railway Shell 또는 Variables에서 인증 진행

## 지원하는 방법

- GitHub CLI: device code (`gh auth login --web`)
- Claude: `ANTHROPIC_API_KEY` 또는 `CLAUDE_CODE_OAUTH_TOKEN`
- Codex: `OPENAI_API_KEY` 또는 `codex login --device-auth`
