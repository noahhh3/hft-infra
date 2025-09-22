# HFT Monitoring Setup
Overview and instruction set for monitoring trading systems using grafana and loki

## Server Setup
Depending on needs scale as you see fit. For our purposes one server on hetzner is enough to host both loki and grafana. On the networking side we want to be able to ingest from our database and real time trading system in AWS


## Grafana Service
Will use for monitoring markets, internal risk, logs and more...

Instructions:
1. Make sure docker is installed on the server: ubuntu docs(https://docs.docker.com/engine/install/ubuntu/)
2. After installing docker, lets begin setting up the admin credentials for grafana. Because we're a 1 man op and don't really need a more intricate setup than what we demand, we will set the credentials in /etc/default/grafana 600 permissions and pull them with grafana at container start time
3. Create grafana credential file with env: GF_SECURITY_ADMIN_PASSWORD=your_secure_password
4. Create volume path on host for retention with restarts. Creates volume for host in /opt/grafana/data with user id 472 owning permissions on the dir (user id of grafana container)
- sudo mkdir -p /opt/grafana/data
- sudo chown 472:472 /opt/grafana/data 
5. Next we need to setup the linux user that the service will run through because we don't want to have everything run through the root user in case of a hacker getting in the container.
- sudo useradd -r -s /bin/false grafana-admin
- sudo usermod -aG docker grafana-admin
What this does is create a system user (-r) with -s /bin/false no shell, meaning not interactive login. Commands can still be issued through the user via root user or system daemon
6. We are running on hetzner and hetzner often has outages and we dont want to have to restart the docker container everytime the server undergoes maintenance. So we are going to use systemd to automatically handle this. However if you dont feel like using systemd, here is the plain docker run command: 
    /usr/bin/docker run --name grafana \
    -p 3000:3000 \
    --env-file /etc/default/grafana \
    -v /opt/grafana/data:/var/lib/grafana \
    grafana/grafana:latest
7. Setup and run like a systemd service. File example in grafana/grafana.service
1. Create the service file:
sudo nano /etc/systemd/system/grafana.service

2. Reload systemd to recognize the new service:
sudo systemctl daemon-reload

3. Enable the service to start on boot:
sudo systemctl enable grafana.service

4. Start the service immediately:
sudo systemctl start grafana.service

5. Check status:
sudo systemctl status grafana.service

## Loki Logging Service