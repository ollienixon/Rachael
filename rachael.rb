# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

require 'rubygems'
require 'cinch'

# Database stuff
require 'data_mapper'
require 'dm-postgres-adapter'
require 'do_postgres'

# Web stuff
require 'mechanize'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'openssl'

require 'date'
require 'cgi'

# Encoding issues
require 'iconv'

# Bitly API interfacing
require 'bitly'


# Global vars
$BOTNICK       = "" # Bot nick
$BOTPASSWORD   = "" # Nickserv password
$BOTOWNER      = "" # Make sure this is lowercase
$BOTURL        = "" # Help page
$BOTGIT        = "https://github.com/ibkshash/Rachael"

# API Keys
$BINGAPI       = "" # For bing search and Translate plugins
$BITLYUSER     = "" # bitly username | Many plugins use this
$BITLYAPI      = "" # bitly api key  |
$LASTFMAPI     = "" # For all last.fm functions
$WOLFRAMAPI    = "" # For Answers


DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb') # This is what Heroku uses

class LastfmDB 
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
	property(:username, String)
end 

class IgnoreDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
end 

class PassiveDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:channel, String, :unique => true)
end 

class JoinDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:channel, String, :unique => true)
end 

class AdminDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
end 

class InsultDB 
	include DataMapper::Resource
	property(:id, Serial)
	property(:insult, Text)
end 

DataMapper.finalize

# Ignore list
def ignore_nick(user)
	check = IgnoreDB.first(:nick => user.downcase)
	if check.nil?
		return nil
	else
		return true
	end
end

# Passive on/off
def disable_passive(channel)
	check = PassiveDB.first(:channel => channel.downcase)
	if check.nil?
		return nil
	else
		return true
	end
end

# Bot admins
def check_admin(user)
	user.refresh
	@admins = AdminDB.first(:nick => user.authname.downcase)
end


# Basic plugins
require_relative './plugins/basic.rb'
require_relative './plugins/admin.rb'             # Admin

# Advacned plugins
require_relative './plugins/userset.rb'           # Set options
require_relative './plugins/urbandictionary.rb'   # UrbanDictionary
require_relative './plugins/weather.rb'           # Weather
require_relative './plugins/lastfm.rb'            # Lastfm
require_relative './plugins/uri.rb'               # Uri
require_relative './plugins/translate.rb'         # Translate
require_relative './plugins/twitter.rb'           # Twitter
require_relative './plugins/hello.rb'             # Insult
require_relative './plugins/8ball.rb'             # Eightball
require_relative './plugins/rand.rb'              # Pick
require_relative './plugins/youtube.rb'           # Youtube
require_relative './plugins/bing.rb'              # Bing
require_relative './plugins/answers.rb'           # Answers


bot = Cinch::Bot.new do
	configure do |c|
		c.plugins.prefix    = /^:/
		c.server            = ""
		c.port              = 6697
		c.ssl.use           = true
		c.ssl.verify        = false
		c.nick              = $BOTNICK
		c.realname          = $BOTNICK
		c.user              = $BOTNICK
		c.channels          = [] # Leave this empty
		c.plugins.plugins   = [Basic, Admin, UserSet, UrbanDictionary, Weather, Lastfm, Uri, Translate, Twitter, Insult, Eightball, Pick, Youtube, Bing, Answers]
	end
end

bot.start
