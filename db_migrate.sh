#!/bin/sh

cd /home/app/snpr
exec 2>&1
exec bash -l -c 'chpst -u app bundle exec rake db:migrate'
