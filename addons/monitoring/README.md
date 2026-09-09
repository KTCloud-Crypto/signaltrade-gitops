# 모니터링

Prometheus, Loki, Alloy, Grafana, PostgreSQL exporter와 보안 접근 로그 수집기를 Argo CD로 배포하는 Helm chart입니다. `dashboards/`의 Grafana 대시보드는 `grafana-dashboards` ConfigMap으로 자동 패키징되어 함께 배포됩니다.

보안 접근 로그는 CloudFront와 ALB가 `signaltrade-security-access-logs-832496385575` 버킷의 `cloudfront/`, `alb/` prefix에 기록하고, S3 Object Created 알림을 `signaltrade-security-log-ingestion-staging` SQS로 보냅니다. `security-log-collector` Vector Pod가 SQS를 소비해 원문을 정규화한 뒤 내부 Loki로 전송합니다. 수집 Pod에는 `security-log-collector-access.yml` CloudFormation 스택으로 EKS Pod Identity를 먼저 연결해야 하며 AWS access key를 Kubernetes Secret에 저장하지 않습니다.

배포 후 다음 순서로 확인합니다.

1. SQS의 visible message가 감소하고 dead-letter queue로 이동한 메시지가 없는지 확인합니다.
2. `kubectl -n signaltrade-staging logs deploy/security-log-collector`에서 S3, SQS, VRL 오류가 없는지 확인합니다.
3. Grafana Explore에서 `{log_type="security_access"}`를 조회해 `edge-alb`, `edge-cloudfront` 로그가 모두 보이는지 확인합니다.
4. `SignalTrade 보안 운영` 대시보드에서 의심 경로와 401·403 원천 IP를 확인합니다.

CloudFront 파서는 standard log의 탭 구분 기본 필드 순서를 사용합니다. CloudFront 출력 필드를 사용자 정의하거나 JSON/Parquet 형식을 선택했다면 `security-access-logs.yaml`의 필드 매핑도 함께 변경해야 합니다.

Prometheus는 Kubernetes API에서 `app.kubernetes.io/component=api|worker` Pod를 발견하고 `http|metrics` 이름의 포트를 Pod별로 수집합니다. ServiceAccount에는 Pod 조회 전용 읽기 권한만 부여합니다.

`kube-state-metrics`는 Pod·Deployment·Job·HPA·PVC 상태를, `node-exporter`는 노드 CPU·메모리·파일시스템을 제공합니다. Prometheus는 kubelet cAdvisor를 통해 컨테이너 CPU·메모리·네트워크 사용량도 수집합니다.

## 확인할 항목

- Pod 준비 상태, 재시작 횟수, CPU·메모리
- API 응답 시간과 오류 비율
- Strategy 신호 수, Trading 주문 성공·실패 수
- Outbox pending 건수, SQS Queue 적체와 DLQ 메시지
- RDS 연결·저장 공간, Redis 메모리

서비스는 표준 출력으로 구조화 로그를 남기고, Token·거래소 키·Authorization 값은 로그에 기록하지 않습니다. 운영에서는 Prometheus·Grafana로 애플리케이션 지표를 보고, CloudWatch로 AWS 인프라 지표와 로그를 함께 확인합니다.
