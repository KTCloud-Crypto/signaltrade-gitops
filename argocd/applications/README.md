# Argo CD Applications

- `signaltrade-staging.yaml`: MSA API, Worker, migration, Service, Ingress 배포
- `observability-staging.yaml`: Prometheus, Grafana, Loki, Alloy 배포

AWS Load Balancer Controller와 External Secrets Operator를 먼저 설치하고 정상 동작을 확인한 뒤 동기화합니다. Argo CD는 `argocd/install/kustomization.yaml`에 고정된 버전으로 설치합니다. `projects/signaltrade.yaml`을 먼저 적용한 다음 Application을 적용합니다. staging Application은 자동 동기화, self-heal, prune을 사용합니다. MSA Ingress는 별도 cutover 전까지 staging values에서 비활성화합니다.
