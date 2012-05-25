# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

require 'rubygems'
require 'heroku'

require 'cinch'

# Database stuff
require 'dm-core'
require 'dm-postgres-adapter'
require 'do_postgres'

# Web stuff
require 'mechanize'
require 'addressable/uri'
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

# Twitter Feed
$TWITTERFEED    = ""
$TWITTERCHANNEL = ""

# API Keys
$BINGAPI       = "" # For bing search and Translate plugins
$BITLYUSER     = "" # bitly username | Many plugins use this
$BITLYAPI      = "" # bitly api key  |
$LASTFMAPI     = "" # For all last.fm functions
$WOLFRAMAPI    = "" # For Answers

# This is for SQLite
DBFILE = "/path/to/sqlite.db"
DataMapper.setup(:default, "sqlite3://" + DBFILE)

# This is for postgres (Heroku)
# DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb') 

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

class LocationDB 
	include DataMapper::Resource
	property(:id, Serial)
	property(:nick, String, :unique => true)
	property(:location, String)
end 

class PassiveDB
	include DataMapper::Resource
	property(:id, Serial)
	property(:channel, String, :unique => true)
end 

class PassiveFDB
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


# This is for sqlite

if(!File.exists?(DBFILE))
	DataMapper.auto_migrate!
elsif(File.exists?(DBFILE))
	DataMapper.auto_upgrade!
end


# Ignore list
def ignore_nick(user)
	check = IgnoreDB.first(:nick => user.downcase)
	check.nil? ? (return nil) : (return true)
end

# Passive on/off
def disable_passive(channel)
	check = PassiveDB.first(:channel => channel.downcase)
	check.nil? ? (return nil) : (return true)
end

# Passive on/off
def disable_passive_files(channel)
	check = PassiveFDB.first(:channel => channel.downcase)
	check.nil? ? (return nil) : (return true)
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
require_relative './plugins/userset.rb'           # UserSet
require_relative './plugins/urbandictionary.rb'   # UrbanDictionary
require_relative './plugins/weather.rb'           # Weather
require_relative './plugins/lastfm.rb'            # Lastfm
require_relative './plugins/uri.rb'               # Uri
require_relative './plugins/translate.rb'         # Translate
require_relative './plugins/twitter.rb'           # Twitter
#require_relative './plugins/tweetfeed.rb'        # TweetFeed
require_relative './plugins/hello.rb'             # Insult
require_relative './plugins/8ball.rb'             # Eightball
require_relative './plugins/rand.rb'              # Pick
require_relative './plugins/youtube.rb'           # Youtube
require_relative './plugins/bing.rb'              # Bing
require_relative './plugins/google.rb'            # Google
require_relative './plugins/answers.rb'           # Answers
require_relative './plugins/tvrage.rb'            # Tvrage



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
		c.channels          = []
		c.plugins.plugins   = [
			Basic, 
			Admin, 
			UserSet, 
			UrbanDictionary, 
			Weather, 
			Lastfm, 
			Uri, 
			Translate, 
			Twitter, 
			#TweetFeed,
			Insult, 
			Eightball, 
			Pick, 
			Youtube, 
			Bing, 
			Google,
			Answers, 
			Tvrage
		]
	end
end

bot.start
