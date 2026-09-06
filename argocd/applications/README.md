# Argo CD Applications

- `signaltrade-staging.yaml`: MSA API, Worker, migration, Service, Ingress 배포
- `observability-staging.yaml`: Prometheus, Grafana, Loki, Alloy 배포

AWS Load Balancer Controller와 External Secrets Operator를 먼저 설치하고 정상 동작을 확인한 뒤 동기화합니다. Argo CD는 `argocd/install/kustomization.yaml`에 고정된 버전으로 설치합니다. `projects/signaltrade.yaml`을 먼저 적용한 다음 Application을 적용합니다. staging Application은 자동 동기화, self-heal, prune을 사용하며 Ingress는 모든 API 경로를 MSA 서비스로 전달합니다.

production values에는 staging에서 검증한 immutable Git SHA만 승격합니다. production 클러스터, Pod Identity, Secret 값이 준비된 뒤 수동 승인 Application으로 배포하고 Ingress는 검증 완료 전까지 비활성 상태로 유지합니다.
