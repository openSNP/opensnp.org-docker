#!/bin/sh

cd /home/app/webapp
exec 2>&1
exec bash -l -c 'chpst -u app bundle exec rake db:migrate'
