# encoding: utf-8

class Twitter
  include Cinch::Plugin

  match /tw(?:itter)? (.+)/

  def execute(m, query)
    begin
      url = Nokogiri::XML(open("http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{query}&count=1&include_rts=true&exclude_replies=true", :read_timeout=>1).read)

      tweettext   = url.xpath("//status/text").text
      name        = url.xpath("//statuses/status/user/name").text
      screenname  = url.xpath("//statuses/status/user/screen_name").text

      m.reply "12Twitter #{name} (@#{screenname}): #{tweettext}"
    rescue Timeout::Error
      retry
    rescue
      m.reply "12Twitter Error getting tweet for #{query}"
    end
  end
end