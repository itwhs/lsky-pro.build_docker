#!/bin/bash
set -eu

if [ ! -e '/var/www/html/public/index.php' ]; then
    chown -R www-data /var/www/lsky
    chgrp -R www-data /var/www/lsky
    chmod -R 755 /var/www/lsky
    cp -ar /var/www/lsky/* /var/www/html/
    cp -ar /var/www/lsky/.env* /var/www/html
fi

exec "$@"
