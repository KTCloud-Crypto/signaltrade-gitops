# 모니터링

Prometheus, Loki, Alloy, Grafana와 PostgreSQL exporter를 Argo CD로 배포하는 Helm chart입니다. `dashboards/`의 Grafana 대시보드는 `grafana-dashboards` ConfigMap으로 자동 패키징되어 함께 배포됩니다.

Prometheus는 Kubernetes API에서 `app.kubernetes.io/component=api|worker` Pod를 발견하고 `http|metrics` 이름의 포트를 Pod별로 수집합니다. ServiceAccount에는 Pod 조회 전용 읽기 권한만 부여합니다.

## 확인할 항목

- Pod 준비 상태, 재시작 횟수, CPU·메모리
- API 응답 시간과 오류 비율
- Strategy 신호 수, Trading 주문 성공·실패 수
- Outbox pending 건수, SQS Queue 적체와 DLQ 메시지
- RDS 연결·저장 공간, Redis 메모리

서비스는 표준 출력으로 구조화 로그를 남기고, Token·거래소 키·Authorization 값은 로그에 기록하지 않습니다. 운영에서는 Prometheus·Grafana로 애플리케이션 지표를 보고, CloudWatch로 AWS 인프라 지표와 로그를 함께 확인합니다.
