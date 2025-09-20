/usr/bin/docker run --name loki \
    -p 3100:3100 \
    -v /opt/loki/config:/etc/loki \
    -v /opt/loki/data:/tmp/loki \
    grafana/loki:latest \
    -config.file=/etc/loki/local-config.yaml