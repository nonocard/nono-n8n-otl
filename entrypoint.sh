#!/bin/sh
# Hashea el password en el arranque: las funciones de template de Railway
# generan secretos en texto plano, no bcrypt.
set -eu

: "${PORT:=8080}"
: "${UI_USERNAME:=admin}"

# ${{jaeger.RAILWAY_PRIVATE_DOMAIN}} se resuelve vacío durante el deploy del
# template (el servicio aún no existe), así que caemos al hostname determinístico.
case "${JAEGER_UPSTREAM:-}" in
  ''|:*) JAEGER_UPSTREAM="jaeger.railway.internal:16686" ;;
esac

if [ -z "${UI_PASSWORD:-}" ]; then
  echo "FATAL: UI_PASSWORD no está definido; no sirvo la UI sin auth." >&2
  exit 1
fi

UI_PASSWORD_HASH="$(caddy hash-password --plaintext "$UI_PASSWORD")"
[ -n "$UI_PASSWORD_HASH" ] || { echo "FATAL: no pude hashear UI_PASSWORD." >&2; exit 1; }

export PORT UI_USERNAME UI_PASSWORD_HASH JAEGER_UPSTREAM
unset UI_PASSWORD

caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
