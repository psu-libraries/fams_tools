#!/bin/bash

set -e
rm -f /ai_integration/tmp/pids/server.pid

rake db:create
rake db:migrate

bundle exec rails s -p 3000 -b '0.0.0.0'
