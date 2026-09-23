# jaeger-railway

Template de Railway: Jaeger v2 (Badger) + gateway Caddy. Desplegar DENTRO del
proyecto de n8n (la red privada no cruza proyectos).

## Servicio `jaeger` — Root Directory: /jaeger — sin networking público
| Variable        | Valor   |
|-----------------|---------|
| RAILWAY_RUN_UID | 0       |
| PORT            | 13133   |
| SPAN_TTL        | 168h    |
Healthcheck: /status · Volumen: /data · Réplicas: 1

## Servicio `gateway` — Root Directory: /gateway — dominio público (tras WAF)
| Variable        | Valor                                       |
|-----------------|---------------------------------------------|
| UI_USERNAME     | admin                                       |
| UI_PASSWORD     | ${{secret(32)}}                             |
| JAEGER_UPSTREAM | ${{jaeger.RAILWAY_PRIVATE_DOMAIN}}:16686    |
Healthcheck: /healthz

## n8n (main, worker y webhook — TODOS)
  N8N_OTEL_ENABLED=true
  N8N_OTEL_EXPORTER_OTLP_ENDPOINT=http://${{jaeger.RAILWAY_PRIVATE_DOMAIN}}:4318
  N8N_AGENTS_TRACING_RECORD_INPUTS=false
  N8N_AGENTS_TRACING_RECORD_OUTPUTS=false
