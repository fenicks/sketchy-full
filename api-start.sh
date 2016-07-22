#!/usr/bin/env bash

function _init {
    echo 'net.core.somaxconn = 1024' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p

    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' | sudo tee ${thp_path}/enabled
    echo 'never' | sudo tee ${thp_path}/defrag

    unset thp_path
}

_init
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
