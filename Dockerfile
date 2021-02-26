FROM ubuntu:bionic
ENV TZ=Europe/London
ENV VER=6.5.9
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && apt-get update \
  && apt-get install -y php \
    php-curl \
    php-gd \  
    wget \
    unzip

RUN cd /tmp \
  && wget -O jamroom.zip https://www.jamroom.net/networkmarket/core_download/jamroom-open-source.zip \
  && rm /var/www/html/index.html \
  && ln -s /var/www/html jamroom-open-source \
  && unzip jamroom.zip \
  && rm jamroom.zip \
  && rm /tmp/jamroom-open-source

RUN	{ \
		echo '<VirtualHost *:80>'; \
		echo '     DocumentRoot /var/www/html/'; \
		echo '     ServerName example.com'; \
		echo '     <Directory /var/www/html/>'; \
		echo '          Options FollowSymlinks'; \
		echo '          AllowOverride All'; \
		echo '          Require all granted'; \
		echo '     </Directory>'; \
		echo '     ErrorLog ${APACHE_LOG_DIR}/jamroom-error.log'; \
		echo '     CustomLog ${APACHE_LOG_DIR}/jamroom-access.log combined'; \
		echo '</VirtualHost>'; \
	} > /etc/apache2/sites-available/jamroom.conf 

RUN chown -R www-data:www-data /var/www/html/ \
  && chmod -R 755 /var/www/html/ \
  && a2enmod rewrite \
  && a2ensite jamroom.conf

EXPOSE 80
CMD apachectl -D FOREGROUND
