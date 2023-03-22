FROM phusion/baseimage:focal-1.1.0
MAINTAINER Dung DUONG <dung.duong@mati.com.vn>
ENV REFRESHED_AT 22-03-2023

# FROM phusion/baseimage:focal-1.1.0
# MAINTAINER Matthew Rayner <hello@rayner.io>
# ENV REFRESHED_AT 2021-09-07

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

ARG PHP_VERSION
ENV PHP_VERSION=$PHP_VERSION
ENV SUPERVISOR_VERSION=4.2.2

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1) && \
    groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install postfix python3-setuptools wget git apache2 php${PHP_VERSION}-xdebug libapache2-mod-php${PHP_VERSION} php${PHP_VERSION}-mysql pwgen php${PHP_VERSION}-apcu php${PHP_VERSION}-gd php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring zip unzip php${PHP_VERSION}-zip curl php${PHP_VERSION}-curl && \
  apt-get -y autoremove && \
  apt-get -y clean && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install supervisor 4
RUN curl -L https://pypi.io/packages/source/s/supervisor/supervisor-${SUPERVISOR_VERSION}.tar.gz | tar xvz && \
  cd supervisor-${SUPERVISOR_VERSION}/ && \
  python3 setup.py install

# Add image configuration and scripts
ADD ./supporting_files/start-apache2.sh /start-apache2.sh
ADD ./supporting_files/run.sh /run.sh
ADD supporting_files/supervisord.conf /etc/supervisor/supervisord.conf
RUN chmod 755 /*.sh

# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# config to enable .htaccess
ADD ./supporting_files/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app/public /var/www/html
ADD ./app/ /app

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app and MySql
VOLUME  ["/app"]

EXPOSE 80 3306
CMD ["/run.sh"]