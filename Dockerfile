# placeholder-wrapper: env-driven agnhost + probe
FROM registry.k8s.io/e2e-test-images/agnhost:2.39
ARG PROBE_VER=v0.4.25
ADD https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${PROBE_VER}/grpc_health_probe-linux-amd64 /bin/grpc-health-probe
RUN chmod +x /bin/grpc-health-probe

# Small entrypoint to map LOG_LEVEL → --v
# Accepts LOG_LEVEL=[error|warn|info|debug|trace] or LOG_LEVEL_V=<int>
ADD <<'SH' /entrypoint.sh
#!/bin/sh
PORT="${PORT:-3000}"
lvl="${LOG_LEVEL:-info}"
case "$lvl" in
  error) v=0;;
  warn|warning) v=1;;
  info) v=2;;
  debug) v=4;;
  trace) v=6;;
  *) v="${LOG_LEVEL_V:-2}";;
esac
exec /agnhost grpc-health-checking --port="${PORT}" --v="${v}"
SH
RUN chmod +x /entrypoint.sh

ENV PORT=3000 LOG_LEVEL=info
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
