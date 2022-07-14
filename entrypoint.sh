#!/bin/bash
set -eu

if [ ! -e '/var/www/html/public/index.php' ]; then
    chown -R www-data /var/www/lsky
    chgrp -R www-data /var/www/lsky
    chmod -R 755 /var/www/lsky
    cp -ar /var/www/lsky /var/www/html
    rm -rf /var/www/html/.env
fi
echo "本次未执行初始化操作.默认http为:http://`tail -n1 /etc/hosts |awk '{print$1}'`:80"

exec "$@"
