# allow execution access
# chmod +x ./script_activate_ssl.sh

#!/bin/bash

DOMAIN="lizardkinglk.xyz"
EMAIL="chansanfdo@gmail.com"
APP_DIR="$HOME/amonitor-app"

echo "info. generating ssl certificate started..."
echo ""

echo "info. validating global DNS mapping registration records..."
CURRENT_VM_IP=$(curl -s https://ipify.org)
DOMAIN_IP=$(dig +short $DOMAIN | tail -n1)

if [ "$CURRENT_VM_IP" != "$DOMAIN_IP" ]; then
    echo "error. your domain '$DOMAIN' is still pointing to IP '$DOMAIN_IP'."
    echo "please log into Hostinger/your hosting service and change the A Record to this VM's IP: $CURRENT_VM_IP"
    echo "once updated, wait a few minutes for propagation and run this script again!"
    exit 1
fi

echo "info. DNS Records match your current VM IP location."

echo "info. temporarily shutting down Nginx proxy container..."
cd $APP_DIR
docker compose -f docker-compose.yml -f docker-compose.prod.yml down || true

echo "info. fetching official secure SSL keys from Let's Encrypt..."
sudo certbot certonly --standalone \
  -d $DOMAIN -d www.$DOMAIN \
  --non-interactive --agree-tos --email $EMAIL

if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "error. certbot challenge failed. reverting container state to standard HTTP mode..."
    docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
    exit 1
fi

echo "info. security certificates successfully written to VM disk storage."

echo "info. rewriting nginx.prod.conf file to permanently activate Port 443..."

cat << EOF > $APP_DIR/nginx.prod.conf
events { worker_connections 1024; }

http {
    resolver 127.0.0.11 valid=5s;

    # Automated redirect from Port 80 HTTP to secure Port 443 HTTPS
    server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;
        return 301 https://\$host\$request_uri;
    }

    # Secure Production HTTPS Routing Gateway Engine
    server {
        listen 443 ssl;
        server_name $DOMAIN www.$DOMAIN;

        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

        location /api/azure-alerts {
            set \$backend http://dotnet_api:80;
            proxy_pass \$backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        location / {
            set \$dashboard http://grafana:3000;
            proxy_pass \$dashboard;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;

            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
EOF

echo "info. booting updated secure container infrastructure stack..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo ""
echo "=========================================================================="
echo "info. your ecosystem is now encrypted over secure HTTPS link paths."
echo "webhook target URI: https://$DOMAIN/api/azure-alerts"
echo "=========================================================================="