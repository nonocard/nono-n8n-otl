# Pinea versión exacta. Verifica la última 3.x en hub.docker.com/r/prom/prometheus
FROM prom/prometheus:v3.5.0
COPY prometheus.yml /etc/prometheus/prometheus.yml
CMD ["--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus", "--storage.tsdb.retention.time=180d", "--web.listen-address=[::]:9090"]
