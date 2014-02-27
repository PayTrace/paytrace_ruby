#!/bin/sh

apt-get update
apt-get install -y git rake ruby-bundler curl tmux 

# Get newest RVM
\curl -sSL https://get.rvm.io | bash

# Put user vagrant in the rvm group
usermod -a -G rvm vagrant

# Install the version of Ruby we use
/usr/local/rvm/bin/rvm install 2.1.0

su - vagrant <<END_OF_COMMANDS
    # Set up the system from the main shared folder
    cd /vagrant

    # Make sure the latest version of bundler is installed
    gem update bundler

    bundle install
END_OF_COMMANDS
