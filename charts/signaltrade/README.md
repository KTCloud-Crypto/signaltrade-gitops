# SignalTrade Helm Chart

- API: Identity, Strategy, Trading, Portfolio
- Worker: Messaging, Strategy, Trading, Portfolio, Notification
- 공통: ExternalSecret, ServiceAccount, migration PreSync Job, ALB Ingress, NetworkPolicy

Secret 값은 저장하지 않고 AWS Secrets Manager의 환경별 경로만 참조합니다. 이미지 tag는 `environments/<environment>/values.yaml`에서 변경합니다.

각 서비스의 Kubernetes Secret은 환경별 `common`과 `database`를 기본으로 병합하고,
Identity와 Notification만 각각의 전용 Secret을 추가로 병합합니다. GitOps에는 Secret 값이
아닌 `signaltrade/<environment>/<category>` 경로만 기록합니다.
