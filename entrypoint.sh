#!/bin/bash

sleep 1000

set -e
rm -f /fams_tools/tmp/pids/server.pid

rake db:create
rake db:migrate

bundle exec rails s -p 3000 -b '0.0.0.0'
