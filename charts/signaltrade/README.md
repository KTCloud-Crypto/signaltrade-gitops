# SignalTrade Helm Chart

- API: Identity, Strategy, Trading, Portfolio
- Worker: Messaging, Strategy, Trading, Portfolio, Notification
- 공통: ExternalSecret, ServiceAccount, migration PreSync Job, ALB Ingress, NetworkPolicy

Secret 값은 저장하지 않고 AWS Secrets Manager의 환경별 경로만 참조합니다. 이미지 tag는 `environments/<environment>/values.yaml`에서 변경합니다.
