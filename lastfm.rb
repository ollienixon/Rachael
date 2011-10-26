# encoding: utf-8

$apiKey = ""

class Alias
  include Cinch::Plugin

  match /alias (\S+)/
  def execute(m, query)
    f = File.open("./lastfm.xml")
    @items = Nokogiri::XML(f)
    f.close

    check = @items.xpath("//users/nick[@irc='#{m.user.nick.downcase}']").text

    if check == ""
      @items.xpath('//users').each do |xml|
        nick = Nokogiri::XML::Node.new "nick", @items
        nick['irc'] = m.user.nick.downcase
        nick.content = URI.escape(query.downcase)
        xml.add_child(nick)
      end
    else
      @items.xpath("//users/nick[@irc='#{m.user.nick.downcase}']").each do |oof|
        oof.content = URI.escape(query.downcase)
      end
    end

    file = File.open("./lastfm.xml",'w')
    file.puts @items.to_xml
    file.close

    m.reply "#{m.user.nick}: last.fm user updated to: #{query}"
  end

end

=begin

    Last.fm charts

=end

class Lastfm
  include Cinch::Plugin

  match /lastfm (.+)/, method: :charts_user
  match /lastfm$/, method: :charts

  def charts_user(m, query)

    retrys = 2

    begin
      check = Nokogiri::XML(open("./lastfm.xml").read)
      check = check.xpath("//users/nick[@irc='#{URI.escape(query.downcase)}']").text

      if check == "" 
        var = URI.escape(query)
        user = "#{var}"
      else
        var = check
        user = "#{URI.escape(query)} (#{var})"
      end

      result = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=user.getweeklyartistchart&user=#{var}&api_key=#{$apiKey}", :read_timeout=>3).read)
      top_artists = result.xpath("//weeklyartistchart/artist")[0..4]
      reply = "Top 5 Weekly artists for #{user}: "
      top_artists.each do |artist|
        name = artist.xpath("name").text
        count = artist.xpath("playcount").text
        reply = reply + "#{name} (#{count}), "
      end
      reply = reply[0..reply.length-3]
    rescue Timeout::Error
      if retrys > 0
        retrys = retrys - 1
        retry
      else
        reply = "Timeout error"
      end
    rescue
      reply = "The user '#{var}' doesn't have a Last.fm account"
    end
    m.reply "0,4Last.fm #{reply}"
  end

  def charts(m)
    user = Nokogiri::XML(open("./lastfm.xml").read)
    user = user.xpath("//nick[@irc='#{m.user.nick.downcase}']").text

    retrys = 2

    begin
      result = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=user.getweeklyartistchart&user=#{URI.escape(user)}&api_key=#{$apiKey}", :read_timeout=>3).read)
      top_artists = result.xpath("//weeklyartistchart/artist")[0..4]
      reply = "Top 5 Weekly artists for #{m.user.nick} (#{user}): "
      top_artists.each do |artist|
        name = artist.xpath("name").text
        count = artist.xpath("playcount").text
        reply = reply + "#{name} (#{count}), "
      end
      reply = reply[0..reply.length-3]
    rescue Timeout::Error
      if retrys > 0
        retrys = retrys - 1
        retry
      else
        reply = "Timeout error"
      end
    rescue
      reply = "The user '#{user}' doesn't have a Last.fm account"
    end
    m.reply "0,4Last.fm #{reply}"
  end
end

=begin

    Compare users

=end

class Compare
  include Cinch::Plugin

  match /compare (\S+)$/, method: :compare
  match /compare (\S+) (\S+)/, method: :compare_two

  def compare_two(m, one, two)

    retrys = 2

    begin

      file = Nokogiri::XML(open("./lastfm.xml").read)
      userone = file.xpath("//users/nick[@irc='#{URI.escape(one.downcase)}']").text
      usertwo = file.xpath("//users/nick[@irc='#{URI.escape(two.downcase)}']").text

      if userone == "" 
        value1 = URI.escape(one)
        userone = URI.escape(one)
      else
        value1 = URI.escape(userone)
        userone = "#{one} (#{userone})"
      end

      if usertwo == "" 
        value2 = URI.escape(two)
        usertwo = URI.escape(two)
      else
        value2 = URI.escape(usertwo)
        usertwo = "#{two} (#{usertwo})"
      end

      result = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=tasteometer.compare&type1=user&type2=user&value1=#{value1}&value2=#{value2}&api_key=#{$apiKey}", :read_timeout=>3).read)
      score = result.xpath("//score").text

      common = result.xpath("//artists/artist")[0..4]
      commonlist = ""
      common.each do |getcommon|
        artist = getcommon.xpath("name").text
        commonlist = commonlist + "#{artist}, "
      end
      commonlist = commonlist[0..commonlist.length-3]
      commonlist = "Common artists include: #{commonlist}" if commonlist != ""

      score = score[2..4]
      scr = "#{score.to_i/10}.#{score.to_i % 10}"

      reply = "#{userone} vs #{usertwo}: #{scr}%. #{commonlist}"
    rescue Timeout::Error
      if retrys > 0
        retrys = retrys - 1
        retry
      else
        reply = "Timeout error"
      end
    rescue
      reply = "Error"
    end
    m.reply "0,4Last.fm #{reply}"
  end

  def compare(m, query)

    retrys = 2

    begin

      file = Nokogiri::XML(open("./lastfm.xml").read)
      user = file.xpath("//nick[@irc='#{m.user.nick.downcase}']").text
      usertwo = file.xpath("//users/nick[@irc='#{URI.escape(query.downcase)}']").text

      if usertwo == "" 
        value2 = URI.escape(query)
        usertwo = query
      else
        value2 = URI.escape(usertwo)
        usertwo = "#{query} (#{usertwo})"
      end

      result = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=tasteometer.compare&type1=user&type2=user&value1=#{URI.escape(user)}&value2=#{value2}&api_key=#{$apiKey}", :read_timeout=>3).read)
      score = result.xpath("//score").text

      common = result.xpath("//artists/artist")[0..4]
      commonlist = ""
      common.each do |getcommon|
        artist = getcommon.xpath("name").text
        commonlist = commonlist + "#{artist}, "
      end
      commonlist = commonlist[0..commonlist.length-3]
      commonlist = "Common artists include: #{commonlist}" if commonlist != ""

      score = score[2..4]
      scr = "#{score.to_i/10}.#{score.to_i % 10}"

      reply = "#{m.user.nick} (#{user}) vs #{usertwo}: #{scr}%. #{commonlist}"
    rescue Timeout::Error
      if retrys > 0
        retrys = retrys - 1
        retry
      else
        reply = "Timeout error"
      end
    rescue
      reply = "Error"
    end
    m.reply "0,4Last.fm #{reply}"
  end
end

=begin

    Get last played track

=end

class NowPlaying
  include Cinch::Plugin

  match /np (.+)/, method: :np_user
  match /np$/, method: :np

  def np_user(m, query)

    retrys = 2

    begin

      check = Nokogiri::XML(open("./lastfm.xml").read)
      check = check.xpath("//users/nick[@irc='#{URI.escape(query.downcase)}']").text

      if check == "" 
        var = URI.escape(query)
        user = "#{var}"
      else
        var = check
        user = "#{URI.escape(query)} (#{var})"
      end
      
      result = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{var}&api_key=#{$apiKey}", :read_timeout=>3).read)

      artist  = result.xpath("//recenttracks/track[1]/artist").text
      track   = result.xpath("//recenttracks/track[1]/name").text
      now     = result.xpath("//recenttracks/track[1]/@nowplaying").text

      tagurl = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=artist.gettoptags&artist=#{URI.escape(artist)}&api_key=#{$apiKey}", :read_timeout=>3).read)
      tags = tagurl.xpath("//toptags/tag")[0..3]
      taglist = ""
      tags.each do |gettags|
        tag = gettags.xpath("name").text
        taglist = taglist + "#{tag}, "
      end
      taglist = taglist[0..taglist.length-3]
      taglist = "(#{taglist})" if taglist != ""

      if now == "true"
        reply = "#{user} is playing: \"#{track}\" by #{artist} #{taglist}"
      else
        reply = "#{user} last played: \"#{track}\" by #{artist} #{taglist}"
      end
    rescue Timeout::Error
      if retrys > 0
        retrys = retrys - 1
        retry
      else
        reply = "Timeout error"
      end
    rescue
      reply = "Error"
    end
      m.reply "0,4Last.fm #{reply}"
  end

  def np(m)
    user = Nokogiri::XML(open("./lastfm.xml").read)
    user = user.xpath("//nick[@irc='#{m.user.nick.downcase}']").text

    retrys = 2

    begin
      result = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{URI.escape(user)}&api_key=#{$apiKey}", :read_timeout=>3).read)

      artist  = result.xpath("//recenttracks/track[1]/artist").text
      track   = result.xpath("//recenttracks/track[1]/name").text
      now     = result.xpath("//recenttracks/track[1]/@nowplaying").text

      tagurl = Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=artist.gettoptags&artist=#{URI.escape(artist)}&api_key=#{$apiKey}", :read_timeout=>3).read)
      tags = tagurl.xpath("//toptags/tag")[0..3]
      taglist = ""
      tags.each do |gettags|
        tag = gettags.xpath("name").text
        taglist = taglist + "#{tag}, "
      end
      taglist = taglist[0..taglist.length-3]
      taglist = "(#{taglist})" if taglist != ""

      if now == "true"
        reply = "#{m.user.nick} (#{user}) is playing: \"#{track}\" by #{artist} #{taglist}"
      else
        reply = "#{m.user.nick} (#{user}) last played: \"#{track}\" by #{artist} #{taglist}"
      end
    rescue Timeout::Error
      if retrys > 0
        retrys = retrys - 1
        retry
      else
        reply = "Timeout error"
      end
    rescue
      reply = "The user '#{user}' doesn't have a Last.fm account"
    end
    m.reply "0,4Last.fm #{reply}"
  end
end
