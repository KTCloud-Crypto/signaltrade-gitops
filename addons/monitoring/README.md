# 모니터링

## 부하 테스트 대시보드

기존 `signaltrade-load-test` UID를 유지합니다. 실행 ID와 시나리오, 실행자(`runner_id`), 단계(`stage`)를 선택하고 실제 테스트 시작·종료 시간으로 시간 범위를 맞춥니다. 두 실행자는 같은 `test_run_id`와 서로 다른 `runner_id`를 사용해야 시계열 충돌을 피할 수 있습니다. 새 태그가 없는 과거 데이터는 필터를 전체로 두고 조회합니다. Grafana annotation으로 부하 시작·종료·회복 확인 시점을 기록할 수 있습니다.

- k6는 Prometheus remote write로 전송하고 `K6_PROMETHEUS_RW_TREND_STATS='p(95),p(99)'`를 설정합니다. 이 화면은 통계 Gauge 방식의 `k6_http_req_duration_seconds_p95/p99`와 `k6_http_req_failed_rate`를 사용합니다. Native histogram 출력은 별도 쿼리가 필요합니다.
- p95/p99와 실패율은 실행자·요청별 원본 시계열입니다. 두 실행자의 백분위수나 실패 비율을 평균·최댓값으로 합쳐 전체 결과라고 표시하지 않습니다. 전체 분포는 합산 가능한 histogram 수집이 필요합니다.
- 목표 VU/RPS는 전체 부하 기준 양의 숫자를 입력합니다. 0은 미설정이며 목표선이 표시되지 않습니다. 수동 목표 입력은 과거 단계의 이력을 저장하지 않으므로 단계별 시간 범위를 선택해 사용합니다. k6 arrival rate는 iteration/s이며 HTTP RPS와 다를 수 있습니다.
- k6 VU는 전역 Gauge이므로 scenario 필터를 적용하지 않습니다. 테스트 완료 후 남는 Gauge를 피하려면 실행기에서 remote-write stale marker 설정을 사용하고, 정확한 실행 시간 범위를 선택합니다.
- 서버·DB·Worker 지표는 k6 실행 ID로 분리되지 않습니다. 선택 시간대의 전체 트래픽이며 서비스 필터와 k6 시나리오의 범위도 일치하는지 확인합니다.
- 데이터 없음은 정상 0건으로 대체하지 않습니다. 사전 점검에서 API·Worker·postgres·kube-state-metrics·node-exporter 수집 상태를 확인하세요.
- 노드 Pod 수는 전체 Namespace를 포함합니다. Pod 필터는 API 서비스와 독립적이므로 Worker도 선택할 수 있습니다.
- Outbox 발행률, 알림 전송률, 계측된 Worker 작업 결과를 표시합니다. 이는 주문 완료율이 아닙니다. SQS 적체·최장 대기 시간, Outbox 대기량, Redis 상태, 업무 완료 지연은 별도 계측·수집 확인이 필요하며 이 대시보드만으로 완전한 회복을 판정하지 않습니다.
- 휴식 중 응답시간·오류·Pending·DB 연결·작업 상태를 관측하고 고정 RPS 마지막 20 RPS 구간을 첫 20 RPS 구간과 비교합니다. 단순히 대기 시간이 지났거나 HPA가 최소 복제 수로 줄었다는 이유만으로 회복 성공을 판정하지 않습니다.

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
