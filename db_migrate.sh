#!/bin/bash

cd /home/app/webapp
chpst -u app bundle exec rake db:migrate
