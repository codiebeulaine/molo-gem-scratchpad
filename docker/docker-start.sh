#!/bin/bash

set -e

# ensure we create the locales first so that Django doesn't complain
LANGUAGE_CODE=en ./manage.py compilemessages

./manage.py migrate --noinput
./manage.py collectstatic --noinput
./manage.py compress

echo "from django.contrib.auth.models import User
if not User.objects.filter(username='admin').count():
    User.objects.create_superuser('admin', 'admin@example.com', 'pass')
" | ./manage.py shell

echo "=> Starting nginx"
nginx; service nginx reload

echo "=> Starting Supervisord"
supervisord -c /etc/supervisord.conf

echo "=> Tailing logs"
tail -qF /var/log/supervisor/*.log
