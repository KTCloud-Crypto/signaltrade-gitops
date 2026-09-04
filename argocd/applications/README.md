# Argo CD Applications

- `signaltrade-staging.yaml`: MSA API, Worker, migration, Service, Ingress 배포
- `observability-staging.yaml`: Prometheus, Grafana, Loki, Alloy 배포

AWS Load Balancer Controller와 External Secrets Operator를 먼저 설치하고 정상 동작을 확인한 뒤 동기화합니다. 초기 cutover 동안 자동 동기화와 자동 삭제는 의도적으로 비활성화합니다.
