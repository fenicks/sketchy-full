#!/usr/bin/env bash

sudo sysctl -w net.core.somaxconn=1024

current_dir=$(cd $(dirname "$0")/.. && pwd)

sudo service postgresql start
sudo -u postgres psql -c "CREATE USER sketchy WITH PASSWORD 'sketchy';" > /dev/null 2>&1
sudo -u postgres psql -c "CREATE DATABASE sketchy OWNER sketchy;" > /dev/null 2>&1

redis-server &

cd ${current_dir}
source sketchenv/bin/activate
python manage.py create_db

celery -A sketchy.celery worker &

python manage.py runserver --host 0.0.0.0 --port 8000
