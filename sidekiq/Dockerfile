FROM opensnp/rails

RUN mkdir /var/run/sidekiq
RUN chown app:app /var/run/sidekiq
RUN touch /etc/service/nginx/down
ADD sidekiq-run /etc/service/sidekiq/run

USER app
RUN bundle exec whenever --update-crontab
RUN cd $(bundle show recommendify); \
    bundle install --path /tmp/recommendify-bundle; \
    bundle exec rake build_native; \
    rm -rf /tmp/recommendify-bundle
USER root
