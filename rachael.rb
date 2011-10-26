# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

require 'rubygems'
require 'cinch'
require 'mechanize'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'date'
require 'cgi'
require 'openssl'
require 'iconv'

#require 'twitter_oauth'
#require 'yaml'

# Ignore list
def ignore_nick(user)
  f = File.open("ignore.txt")
  ignoreNicksArray=[] 
  f.each_line {|line| ignoreNicksArray.push line.gsub(/[\r\n]/, "") }
  ignoreNicksArray.include?(user)
end

# Turns off URL Prasing in select channels
def ignore_channel(channel)
  f = File.open("ignorec.txt")
  ignoreChannelsArray=[] 
  f.each_line {|line| ignoreChannelsArray.push line.gsub(/[\r\n]/, "") }
  ignoreChannelsArray.include?(channel)
end

# Basic plugins
require_relative './basic.rb'

# ``Advacned'' plugins
require_relative './urbandictionary.rb'   # UrbanDictionary
require_relative './weather.rb'           # Weather
require_relative './lastfm.rb'            # Alias, Lastfm, Compare, NowPlaying
require_relative './uri.rb'               # Uri
require_relative './translate.rb'         # Translate
require_relative './twitter.rb'           # Twitter
require_relative './hello.rb'             # Hello
require_relative './8ball.rb'             # Eightball
require_relative './rand.rb'              # Pick
require_relative './tvrage.rb'            # Tvrage

#require_relative './tweet.rb'            # Tweet

bot = Cinch::Bot.new do
  configure do |c|
    c.plugins.prefix    = /^:/
    c.server            = "irc.rizon.net"
    c.nick              = "Rachael"
    c.realname          = "Rachael"
    c.user              = "Rachael"
    c.channels          = []
    c.plugins.plugins   = [Basic, UrbanDictionary, Weather, Alias, Lastfm, Compare, NowPlaying, Uri, Translate, Twitter, Hello, Eightball, Pick, Tvrage]
  end
end

bot.start
