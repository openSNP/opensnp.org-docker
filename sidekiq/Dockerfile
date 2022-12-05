FROM opensnp/rails

RUN mkdir /var/run/sidekiq
RUN chown app:app /var/run/sidekiq
RUN touch /etc/service/nginx/down
COPY sidekiq-run /etc/service/sidekiq/run
RUN rm /etc/cron.d/certbot
USER app
RUN bash -l -c 'bundle exec whenever --update-crontab'
RUN bash -l bin/build_native_recommendify
USER root
