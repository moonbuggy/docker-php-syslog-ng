FROM alpine/git:v2.24.1 as builder

WORKDIR /

RUN git clone https://github.com/OpenAai/php-syslog-ng.git
	
# update PHPExcel
#
RUN git clone https://github.com/PHPOffice/PHPExcel.git \
	&& rm -rf php-syslog-ng/www/html/includes/PHPExcel \
	&& mv PHPExcel/Classes php-syslog-ng/www/html/includes/PHPExcel

# patch for PHP 5.6
#
RUN sed -e "s|$_VERSION =& new version();|$_VERSION = new version();|" -i php-syslog-ng/www/html/includes/version.php

# build the final image
#
FROM moonbuggy2000/alpine-s6-nginx-php-fpm:php5.6

RUN . /etc/contenv_extra \
	&& apk add --no-cache \
		${PHP_PACKAGE}-gd=~${PHP_VERSION} \
		${PHP_PACKAGE}-ldap=~${PHP_VERSION} \
		${PHP_PACKAGE}-mysql=~${PHP_VERSION} \
		${PHP_PACKAGE}-xmlrpc=~${PHP_VERSION} \
		${PHP_PACKAGE}-zlib=~${PHP_VERSION}

COPY --from=builder /php-syslog-ng/www/html /var/www/html
COPY ./etc /etc
COPY ./var /var

VOLUME /var/www/html/config
