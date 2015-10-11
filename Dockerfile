FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install software-properties-common python-software-properties
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install build-essential ruby2.2 ruby2.2-dev ruby-switch git imagemagick libpq5 libpq-dev libhiredis-dev
RUN ruby-switch --set ruby2.2

RUN gem install bundler

#ENV GEM_HOME $HOME/gems
RUN mkdir -p /srv/www
RUN useradd -m -d /srv/www/snpr snpr

RUN git clone https://github.com/gedankenstuecke/snpr.git /srv/www/snpr/current

WORKDIR /srv/www/snpr/current

RUN bundle

ADD database.yml config/database.yml
ADD app_config.yml config/app_config.yml
ADD secret_token secret_token
ADD secret_key_base secret_key_base
RUN mkdir log
RUN mkdir -p tmp/pids
