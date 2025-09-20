/usr/bin/docker run --name grafana \
    -p 3000:3000 \
    --env-file /etc/default/grafana \
    -v /opt/grafana/data:/var/lib/grafana \
    grafana/grafana:latest