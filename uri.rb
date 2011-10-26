# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Uri 
  include Cinch::Plugin
  react_on :channel

  listen_to :channel
  def listen(m)
    return unless ignore_nick(m.user.nick) == false and ignore_channel(m.channel) == false

    if(@agent.nil?)
      @agent = Mechanize.new
      @agent.user_agent_alias = "Windows IE 6"
      @agent.follow_meta_refresh = true
    end

    URI.extract(m.message, ["http", "https"]) do |link|

      uri = URI.parse(link)

      begin
        # Check host
        case uri.host
          when "www.youtube.com"

            yoURL     = URI::split(link)

            begin
              videoId   = yoURL[7]
              doc      = Nokogiri::XML(open("http://gdata.youtube.com/feeds/api/videos/#{videoId[2..12]}?v=2"))

              views     = doc.xpath("//yt:statistics/@viewCount").text
              length    = doc.xpath("//yt:duration/@seconds").text
              name      = doc.xpath("//media:title").text
              rating    = doc.xpath("//gd:rating/@average").text
              likes     = doc.xpath("//yt:rating/@numLikes").text
              dislikes  = doc.xpath("//yt:rating/@numDislikes").text

              views     = views.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
              likes     = likes.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
              dislikes  = dislikes.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse

              length    = length.to_i
              rating    = rating[0..2]

              if length > 3599
                lengthf = [length/3600, length/60 % 60, length % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
              else
                lengthf = [length/60 % 60, length % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
              end

              m.reply "1,0You0,4Tube %s | %s | %s views | Rating: %s (%s|%s)" % [name, lengthf, views, rating, likes, dislikes]
            rescue
              page = @agent.get(link)
              title = page.title.gsub(/\s+/, ' ').strip
              m.reply "0,3Title %s (%s)" % [title, uri.host] # Generic title
            end

          when "boards.4chan.org"

            doc = @agent.get(link)
            bang = URI::split(link)

            if bang[5].include? "/res/"

              op = bang[5].include? bang[8] if bang[8] != nil
              quote = bang[8].include? "q" if bang[8] != nil

              if bang[8] != nil and op == false and quote == false # Get reply post info
                poster    = doc.search("//td[@id=#{bang[8]}]/span[@class='commentpostername']").text
                trip      = doc.search("//td[@id=#{bang[8]}]/span[@class='postertrip']").text
                postid    = bang[8]
                reply     = doc.search("//td[@id=#{bang[8]}]/blockquote").inner_html.gsub("<br>", " ").gsub("<font class=\"unkfunc\">", "3").gsub("</font>", "").gsub(/<\/?[^>]*>/, "").gsub("&gt;", ">")
                image     = doc.search("//td[@id=#{bang[8]}]/a/@href").text

                image = "File: #{image} | " if image != ""
                reply = reply[0..160]+" …" if reply.length > 160

                m.reply "3%s%s No.%s | %s%s" % [poster, trip, postid, image, reply]
              else
                subject   = doc.search("//span[@class='filetitle']").text
                poster    = doc.search("//span[@class='postername']").text
                trip      = doc.search("//form/span[@class='postertrip']").text
                postid    = doc.search("//form/span/a[@class='quotejs'][2]").text
                reply     = doc.search("//form/blockquote[1]").inner_html.gsub("<br>", " ").gsub("<font class=\"unkfunc\">", "3").gsub("</font>", "").gsub(/<\/?[^>]*>/, "").gsub("&gt;", ">")
                image     = doc.search("//form/a[1]/@href").text
                date      = doc.search("//form/a[1]/@href").text

                subject = subject+" " if subject != ""
                reply = "| "+reply if reply != ""
                reply = reply[0..160]+" …" if reply.length > 160

                date      = date[-17..-8] # Get the date from the file name
                t         = date.to_i
                da        = Time.at(t).strftime("%b %d %R")

                m.reply "%s3%s%s (%s) No.%s | File: %s %s" % [subject, poster, trip, da, postid, image, reply]
              end

            else
              page = @agent.get(link)
              title = page.title.gsub(/\s+/, ' ').strip
              m.reply "0,3Title %s (%s)" % [title, uri.host] # Board index title
            end

          else
            page = @agent.get(link)
            title = page.title.gsub(/\s+/, ' ').strip
            m.reply "0,3Title %s (%s)" % [title, uri.host] # Generic title
          end

      rescue OpenURI::HTTPError
        m.reply "0,3Title 404 Page Not Found"
      rescue
        nil
      end
    end
  end
end