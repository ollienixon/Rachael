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
$BOTNICK = "Rachael"
$BOTPASSWORD = ""
$BOTOWNER = "qb" # Make sure this is lowercase
$BOTURL = "http://sjis.me/help.html"
$BOTGIT = "https://github.com/ibkshash/Rachael"

# API Keys
$BINGAPI       = ""
$BITLYUSER     = ""
$BITLYAPI      = ""
$LASTFMAPI     = ""
$WOLFRAMAPI    = ""


DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

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
require_relative './plugins/userset.rb'           # Set options

# ``Advacned'' plugins
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
		c.server            = "irc.rizon.net"
		c.port              = 6697
		c.ssl.use           = true
		c.ssl.verify        = false
		c.nick              = $BOTNICK
		c.realname          = "#DEVELOPERS"
		c.user              = $BOTNICK
		c.channels          = []
		c.plugins.plugins   = [Basic, UserSet, UrbanDictionary, Weather, Lastfm, Uri, Translate, Twitter, Insult, Eightball, Pick, Youtube, Bing, Answers]
	end
end

bot.start
