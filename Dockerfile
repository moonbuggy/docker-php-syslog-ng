ARG PHP_VERSION="5.6"
ARG FROM_IMAGE="moonbuggy2000/alpine-s6-nginx-php-fpm:${PHP_VERSION}"

ARG TARGET_ARCH_TAG="amd64"

## get the source
#
FROM moonbuggy2000/fetcher:latest AS fetcher

WORKDIR /

RUN git clone https://github.com/OpenAai/php-syslog-ng.git
	
# update PHPExcel
RUN git clone https://github.com/PHPOffice/PHPExcel.git \
	&& rm -rf php-syslog-ng/www/html/includes/PHPExcel \
	&& mv PHPExcel/Classes php-syslog-ng/www/html/includes/PHPExcel

# patch for PHP 5.6
RUN sed -e "s|$_VERSION =& new version();|$_VERSION = new version();|" -i php-syslog-ng/www/html/includes/version.php


## build the image
#
FROM "${FROM_IMAGE}" AS builder

# QEMU static binaries from pre_build
ARG QEMU_DIR
ARG QEMU_ARCH=""
COPY _dummyfile "${QEMU_DIR}/qemu-${QEMU_ARCH}-static*" /usr/bin/

ARG PHP_VERSION
ARG PHP_PACKAGE="php5"
RUN . /etc/contenv_extra \
	&& apk add --no-cache \
		${PHP_PACKAGE}-gd=~${PHP_VERSION} \
		${PHP_PACKAGE}-ldap=~${PHP_VERSION} \
		${PHP_PACKAGE}-mysql=~${PHP_VERSION} \
		${PHP_PACKAGE}-xmlrpc=~${PHP_VERSION} \
		${PHP_PACKAGE}-zlib=~${PHP_VERSION}

COPY --from=fetcher /php-syslog-ng/www/html /var/www/html
COPY ./root /

RUN rm -f "/usr/bin/qemu-${QEMU_ARCH}-static" >/dev/null 2>&1


## drop the QEMU binaries
#
FROM "moonbuggy2000/scratch:${TARGET_ARCH_TAG}"

COPY --from=builder / /

VOLUME /var/www/html/config

ARG NGINX_PORT="8080"
EXPOSE "${NGINX_PORT}"

ENTRYPOINT ["/init"]

HEALTHCHECK --start-period=10s --timeout=10s \
	CMD wget --quiet --tries=1 --spider http://127.0.0.1:8080/fpm-ping && echo 'okay' || exit 1
