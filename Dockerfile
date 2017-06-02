FROM phusion/passenger-ruby23:0.9.20

ENV RAILS_ENV production

RUN apt-get -q update
RUN apt-get -qy -o Dpkg::Options::="--force-confold" upgrade
RUN echo 'postfix postfix/mailname string opensnp.org' | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -qy libhiredis-dev postgresql-client-9.5 postfix imagemagick
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN postconf -e myhostname=opensnp.org
ADD start_postfix.sh /etc/my_init.d/91_start_postfix.sh

ADD nginx-http.conf /etc/nginx/conf.d/http.conf
ADD nginx-opensnp.org.conf /etc/nginx/sites-enabled/opensnp.org.conf
RUN sed -i "s/# gzip_types/gzip_types/" /etc/nginx/nginx.conf
RUN sed -i "s/# gzip_vary/gzip_vary/" /etc/nginx/nginx.conf
RUN sed -i "s/# gzip_proxied/gzip_proxied/" /etc/nginx/nginx.conf
RUN sed -i "s/# gzip_http/gzip_http/" /etc/nginx/nginx.conf

RUN rm /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down

ADD db_migrate.sh /etc/my_init.d/90_db_migrate.sh

RUN git clone --depth=1 https://github.com/openSNP/snpr.git /home/app/snpr
WORKDIR /home/app/snpr
RUN rm -rf .git
RUN chown app:app -R /home/app

USER app

ADD database.yml config/database.yml
RUN bundle install --deployment --without test development
RUN cp .env.example .env
RUN bundle exec rake assets:precompile
RUN rm .env

USER root

RUN bin/extract_env_var_names_for_nginx > /etc/nginx/main.d/rails-env.conf

CMD ["/sbin/my_init"]
