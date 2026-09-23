# Pinea versión exacta. Verifica la última 2.x en hub.docker.com/r/jaegertracing/jaeger
FROM jaegertracing/jaeger:2.20.0
COPY config.yaml /etc/jaeger/config.yaml
CMD ["--config", "/etc/jaeger/config.yaml"]
