FROM phusion/passenger-customizable:2.3.1

ENV RAILS_ENV production

RUN usermod -a -G docker_env app

RUN apt-get -q update
RUN apt-get -qy -o Dpkg::Options::="--force-confold" upgrade
RUN echo 'postfix postfix/mailname string opensnp.org' | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -qy libhiredis-dev postgresql-client postfix imagemagick tzdata libpq-dev certbot shared-mime-info python3-certbot-nginx
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN postconf -e myhostname=opensnp.org
COPY postfix /etc/service/postfix/run

COPY nginx /etc/nginx
RUN sed -i "s/# gzip_types/gzip_types/" /etc/nginx/nginx.conf
RUN sed -i "s/# gzip_vary/gzip_vary/" /etc/nginx/nginx.conf
RUN sed -i "s/# gzip_proxied/gzip_proxied/" /etc/nginx/nginx.conf
RUN sed -i "s/# gzip_http/gzip_http/" /etc/nginx/nginx.conf

RUN rm /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down

COPY db_migrate.sh /etc/my_init.d/90_db_migrate.sh

# If SNPR_REV changed, re-evaluate from here.
ARG SNPR_REV

RUN git clone https://github.com/openSNP/snpr /home/app/snpr && \
    cd /home/app/snpr && \
    git checkout $SNPR_REV && \
    git rev-parse HEAD > REVISION && \
    rm -rf .git

WORKDIR /home/app/snpr

RUN chown app:app -R /home/app

RUN /usr/local/rvm/bin/rvm install $(cat .ruby-version)
RUN /usr/local/rvm/bin/rvm alias create default $(cat .ruby-version)

USER app

COPY irbrc /home/app/.irbrc
COPY database.yml config/database.yml
RUN bash -l -c 'gem install bundler'
RUN bash -l -c 'bundle install --jobs=4 --deployment --without test development'
RUN cp .env.development .env
RUN bash -l -c 'bundle exec rake assets:precompile'
RUN rm .env

USER root

RUN bin/extract_env_var_names_for_nginx > /etc/nginx/main.d/rails-env.conf

CMD ["/sbin/my_init"]
