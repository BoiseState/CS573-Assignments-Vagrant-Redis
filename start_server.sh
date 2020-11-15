#!/bin/bash

# This script should be run from inside the virtual machine

sudo systemctl restart redis.service

cd /vagrant

echo "Installing all dependencies (i.e., libraries) specified in the Gemfile"
# bundle install # this command is similar to mvn install

echo "Starting the server..."
ruby server.rb
