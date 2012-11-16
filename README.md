Rachael
=======

An IRC bot written in Ruby using the [Cinch IRC bot framework](https://github.com/cinchrb/cinch "Cinch at Github") designed to be run on Heroku

To install type:
gem install heroku
heroku create --stack cedar
heroku addons:add shared-database:5mb
git push heroku master
heroku scale web=0
heroku scale bot=1