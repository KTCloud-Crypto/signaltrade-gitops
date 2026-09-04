# Local environment

Helm 전환 전까지 로컬 kind 배포를 유지하기 위한 기존 Kustomize 선언입니다.
Core에서 로컬 기반 인프라를 준비한 뒤 `kustomize/apps`의 서비스들을 배포합니다.

`jobs/database-migration`은 migration을 실행할 때만 적용하고, `platform/ingress`는 로컬 ingress-nginx Service 설정에 사용합니다.
