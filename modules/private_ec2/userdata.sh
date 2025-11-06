#!/bin/bash
exec > >(tee -a /var/log/user-data.log) 2>&1
set -eux

# 0) Static health endpoint for ALB
mkdir -p /var/www/html
echo "ok" > /var/www/html/health.html

# 1) Packages
dnf -y update
dnf -y install httpd php php-fpm php-mysqlnd wget tar unzip

# 2) Apache + PHP-FPM via socket
cat >/etc/httpd/conf.d/php-fpm.conf <<'CONF'
<FilesMatch \.php$>
    SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/"
</FilesMatch>
DirectoryIndex index.php index.html
CONF

systemctl enable --now php-fpm
systemctl enable --now httpd

# 3) WordPress files
cd /var/www/html
rm -f index.html || true
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rsync -a wordpress/ .
rm -rf wordpress latest.tar.gz

# 4) wp-config using template vars from Terraform
cat > /var/www/html/wp-config.php <<PHP
<?php
define( 'DB_NAME',     '${DB_NAME}' );
define( 'DB_USER',     '${DB_USER}' );
define( 'DB_PASSWORD', '${DB_PASSWORD}' );
define( 'DB_HOST',     '${DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define('AUTH_KEY',         'changeme');
define('SECURE_AUTH_KEY',  'changeme');
define('LOGGED_IN_KEY',    'changeme');
define('NONCE_KEY',        'changeme');
define('AUTH_SALT',        'changeme');
define('SECURE_AUTH_SALT', 'changeme');
define('LOGGED_IN_SALT',   'changeme');
define('NONCE_SALT',       'changeme');

\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) { define( 'ABSPATH', __DIR__ . '/' ); }
require_once ABSPATH . 'wp-settings.php';
PHP

# 5) Permissions and restart
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
systemctl restart httpd
