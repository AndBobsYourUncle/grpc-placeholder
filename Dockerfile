# placeholder image that serves grpc.health.v1.Health and honors LOG_LEVEL/PORT
FROM registry.k8s.io/e2e-test-images/agnhost:2.39

# add probe
ARG PROBE_VER=v0.4.25
ADD https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${PROBE_VER}/grpc_health_probe-linux-amd64 /bin/grpc-health-probe
RUN chmod +x /bin/grpc-health-probe

# tiny entrypoint that maps LOG_LEVEL to klog --v and optionally silences output
ADD <<'SH' /entrypoint.sh
#!/bin/sh
set -e

PORT="${PORT:-3000}"
lvl="${LOG_LEVEL:-info}"

# Map LOG_LEVEL to klog verbosity and a "quiet" switch
case "$lvl" in
  error) v=0; quiet=1 ;;
  warn|warning) v=1; quiet=1 ;;
  info) v=2; quiet=0 ;;
  debug) v=4; quiet=0 ;;
  trace) v=6; quiet=0 ;;
  *) v="${LOG_LEVEL_V:-2}"; quiet=0 ;;
esac

cmd="/agnhost grpc-health-checking --port=${PORT} --v=${v}"

if [ "$quiet" = "1" ]; then
  # Suppress both stdout and stderr for warn/error levels to hide info logs
  exec sh -c "$cmd >/dev/null 2>&1"
else
  exec sh -c "$cmd"
fi
SH
RUN chmod +x /entrypoint.sh

ENV PORT=3000 LOG_LEVEL=info
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
