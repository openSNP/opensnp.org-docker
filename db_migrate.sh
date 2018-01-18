#!/bin/bash

cd /home/app/webapp
chpst -U app bundle exec rake db:migrate
