# Heroku Lockdown
Protect your heroku apps on a command-by-command basis

## Installation
* Assuming you have the heroku gem installed:

    heroku plugins:install git://github.com/latentflip/heroku-lockdown.git

## Usage
* Create/edit ~/.herokurc
* Add a line for each command and app you want to protect, like so:

    protect db:reset production-app
