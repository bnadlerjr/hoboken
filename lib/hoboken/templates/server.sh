#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if gem list foreman -i
then
  echo 'Foreman detected... starting server with Procfile'
  foreman start
else
  echo 'Foreman not installed... starting server with rackup'
  bundle exec rackup
fi
