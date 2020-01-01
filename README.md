# Docker php-syslog-ng

A Docker container running Nginx, PHP-FPM and php-syslog-ng in Alpine.

## Usage

`docker run -d --name php-syslog-ng -p 8080:8080 moonbuggy2000/php-syslog-ng`

Once the container is started initial configuration is done via the web interface at `http://<host>/install/`.

The image does not include syslog-ng, just the web frontend for viewing data from a syslog-ng SQL database.

### Enviornment variables

* `PUID`          - user ID to run as
* `PGID`          - group ID to run as
* `TZ`            - set `date.timezone` in php.ini
* `NGINX_LOG_ALL` - enable logging of HTTP 200 and 300 responses (accepts: `true`, `false` default: `false`)

### Configuration volume

The configuration file is at `/var/www/html/config/config.php`. If you wish to configure php-syslog-ng manually and not through the web interface you can mount a volume here.

## Links

GitHub: https://github.com/moonbuggy/docker-php-syslog-ng

Docker Hub: https://hub.docker.com/r/moonbuggy2000/php-syslog-ng
