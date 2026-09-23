# jaeger-railway

Template de Railway: OTel Collector + Jaeger v2 (Badger) + Prometheus (SPM) + gateway Caddy. Desplegar DENTRO del
proyecto de n8n (la red privada no cruza proyectos).

Flujo: n8n -> otel-collector:4318 (renombra spans) -> jaeger:4317 -> Badger
                                                   \-> span_metrics -> prometheus

## Servicio `otel-collector` — Root Directory: /otel-collector — sin networking público
Renombra `workflow.execute` / `node.execute` con el nombre del workflow / nodo.
| Variable             | Valor                                    |
|----------------------|------------------------------------------|
| PORT                 | 13133                                    |
| JAEGER_OTLP_ENDPOINT | ${{jaeger.RAILWAY_PRIVATE_DOMAIN}}:4317  |
Healthcheck: /status · Réplicas: 1 · Sin volumen

## Servicio `jaeger` — Root Directory: /jaeger — sin networking público
| Variable        | Valor   |
|-----------------|---------|
| RAILWAY_RUN_UID | 0       |
| PORT            | 13133   |
| SPAN_TTL        | 720h    |
| PROMETHEUS_URL  | http://${{prometheus.RAILWAY_PRIVATE_DOMAIN}}:9090 |
Healthcheck: /status · Volumen: /data (~60 GB) · Réplicas: 1 · RAM: 2 GB

## Servicio `prometheus` — Root Directory: /prometheus — sin networking público
| Variable        | Valor   |
|-----------------|---------|
| RAILWAY_RUN_UID | 0       |
| PORT            | 9090    |
Healthcheck: /-/ready · Volumen: /prometheus · Réplicas: 1
Retención de métricas: 180d (flag en el Dockerfile). Se ven en la pestaña
Monitor de la UI de Jaeger.

## Servicio `gateway` — Root Directory: /gateway — dominio público (tras WAF)
| Variable        | Valor                                       |
|-----------------|---------------------------------------------|
| UI_USERNAME     | admin                                       |
| UI_PASSWORD     | ${{secret(32)}}                             |
| JAEGER_UPSTREAM | ${{jaeger.RAILWAY_PRIVATE_DOMAIN}}:16686    |
Healthcheck: /healthz

## n8n
Settings → OpenTelemetry (o variables N8N_OTEL_* en main, worker y webhook):
  Protocol: HTTP (protobuf)
  Endpoint: http://<dominio privado de otel-collector>:4318
            (en variables: http://${{otel-collector.RAILWAY_PRIVATE_DOMAIN}}:4318)
  Trace path: /v1/traces · Sample rate: 100% · Include node spans: on
  Monitor: Span Kind = Internal (n8n emite todo como internal).
