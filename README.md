# SignalTrade GitOps

환경별로 어떤 SignalTrade 서비스 이미지 조합을 배포할지 선언하는 독립 저장소입니다. 서비스 저장소의 CI는 이미지를 만들고, 이 저장소는 검증된 이미지 tag와 Kubernetes 배포 상태를 선택합니다.

## 운영 흐름

```text
서비스 저장소 CI → ECR image → repository_dispatch
GitOps Actions가 환경별 image tag 커밋 → Argo CD
Argo CD → EKS Deployment·Service·Ingress 동기화
```

## 디렉터리

```text
charts/signaltrade/       공통 Helm Chart와 기본 values
argocd/applications/      Argo CD Application·ApplicationSet
addons/monitoring/        Prometheus·Grafana 등 운영 부가 구성
environments/staging/     staging EKS 환경별 values
environments/production/  운영 EKS 환경별 values
environments/local/       기존 kind용 Kustomize 배포 선언
```

Helm Chart는 API 4개와 Worker 5개, DB migration, ALB Ingress, ExternalSecret을 배포합니다. staging Argo CD Application은 자동 동기화와 self-heal을 사용합니다. 서비스 저장소에는 GitOps 저장소로 dispatch할 수 있는 `GITOPS_DISPATCH_TOKEN` Actions secret이 필요합니다. 로컬 서비스 선언은 kind 환경을 위해 `environments/local/kustomize`에 유지합니다.

CloudFormation, EKS, RDS, ElastiCache, SQS 같은 AWS 기반 인프라와 로컬 kind 기반 구성은 `signaltrade-core`에서 관리합니다. 이 저장소에는 클러스터에 **무엇을 어떤 버전으로 배포할지**만 기록합니다.
