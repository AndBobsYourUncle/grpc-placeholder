# placeholder Dockerfile (publish this to ECR/GHCR)
FROM registry.k8s.io/e2e-test-images/agnhost:2.39
ARG PROBE_VER=v0.4.25
ADD https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${PROBE_VER}/grpc_health_probe-linux-amd64 /bin/grpc-health-probe
RUN chmod +x /bin/grpc-health-probe
ENV PORT=3000
EXPOSE 3000
# Read $PORT, forward as flag; no command override needed in TF
ENTRYPOINT ["/bin/sh","-lc","exec /agnhost grpc-health-checking --port=${PORT:-3000}"]
