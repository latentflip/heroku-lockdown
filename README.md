# Heroku Lockdown
* Protect your heroku apps on a command-by-command basis.
* Only tested so far on heroku setups where you have to add --app to commands.
* If commands like db:reset autorun I don't know if this will work.

## Installation
* Assuming you have the heroku gem installed:

    heroku plugins:install git://github.com/latentflip/heroku-lockdown.git

## Usage
* Create/edit ~/.herokurc
* Add a line for each command and app you want to protect, like so:

    #This will prevent db:reset being run on --app production-app
    protect db:reset production-app
    
