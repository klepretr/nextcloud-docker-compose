echo "## Substitution variables in script and config templates"

export $(grep -v '^#' .env | xargs -d '\n')

envsubst '$NEXTCLOUD_DOMAIN$LETSENCRYPT_MAIL$LETSENCRYPT_STAGING' < script/init-letsencrypt.sh.template > script/init-letsencrypt.sh
chmod +x script/init-letsencrypt.sh

envsubst '$NEXTCLOUD_DOMAIN' < nginx/config/nginx.conf.template > nginx/config/nginx.conf

echo "## Starting for init database (30sec)"
sleep 30s &
TIMER_PID=$!
docker-compose run db &
wait $TIMER_PID
docker-compose down

echo "## Starting for init nextcloud app (2m)"
sleep 2m &
TIMER_PID=$!
docker-compose run php &
wait $TIMER_PID
docker-compose down

echo "## Launching Letsencrypt script"
./script/init-letsencrypt.sh

echo "## Last restart of all components"
docker-compose down
docker-compose up -d

echo "## FINNISH ! you can go to https://${NEXTCLOUD_DOMAIN}/login and access to Nextcloud"
