# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Uri 
	include Cinch::Plugin
	react_on :channel

	def minutes_in_words(timestamp)
		minutes = (((Time.now - timestamp).abs)/60).round

		return nil if minutes < 0

		case minutes
		when 0..1      then "Just now"
		when 2..59     then "#{minutes.to_s} minutes ago"
		when 60..1439        
			words = (minutes/60)
			if words > 1
				"#{words.to_s} hours ago"
			else
				"#{words.to_s} hour ago"
			end
		when 1440..11519     
			words = (minutes/1440)
			if words > 1
				"#{words.to_s} days ago"
			else
				"#{words.to_s} day ago"
			end
		when 11520..43199    
			words = (minutes/11520)
			if words > 1
				"#{words.to_s} weeks ago"
			else
				"#{words.to_s} week ago"
			end
		when 43200..525599   
			words = (minutes/43200)
			if words > 1
				"#{words.to_s} months ago"
			else
				"#{words.to_s} month ago"
			end
		else                      
			words = (minutes/525600)
			if words > 1
				"#{words.to_s} years ago"
			else
				"#{words.to_s} year ago"
			end
		end
	end

	listen_to :channel
	def listen(m)
		return unless ignore_nick(m.user.nick).nil? and disable_passive(m.channel.name).nil?

		URI.extract(m.message, ["http", "https"]) do |link|

			uri = URI.parse(link)

			begin

				if(@agent.nil?)
					@agent = Mechanize.new
					@agent.user_agent_alias = "Windows IE 7"
					@agent.follow_meta_refresh = true
					@agent.redirect_ok = true
				end

				if uri.host == "t.co"
					final_uri = ''
					open(link) { |h| final_uri = h.base_uri }

					link = final_uri.to_s
					uri = URI.parse(final_uri.to_s)
				end

				begin
					page = @agent.head link
				rescue
					page = @agent.get link
				end

				# Title
				if page.header['content-type'].include? "html"

					case uri.host
					when "boards.4chan.org"

						doc = @agent.get(link)
						bang = URI::split(link)

						if bang[5].include? "/res/"

							op = bang[5].include? bang[8] if bang[8] != nil
							quote = bang[8].include? "q" if bang[8] != nil

							# Reply
							if bang[8] != nil and op == false and quote == false 
								poster    = doc.search("//td[@id=#{bang[8]}]/span[@class='commentpostername']").text
								trip      = doc.search("//td[@id=#{bang[8]}]/span[@class='postertrip']").text
								postid    = bang[8]
								reply     = doc.search("//td[@id=#{bang[8]}]/blockquote").inner_html.gsub("<br>", " ").gsub("<font class=\"unkfunc\">", "3").gsub("</font>", "").gsub(/<\/?[^>]*>/, "").gsub("&gt;", ">")
								image     = doc.search("//td[@id=#{bang[8]}]/a/@href").text

								image = "File: #{image} | " if image.length > 1
								reply = reply[0..160]+" …" if reply.length > 160

								m.reply "3%s%s No.%s | %s%s" % [poster, trip, postid, image, reply]
							# OP
							else
								subject   = doc.search("//span[@class='filetitle']").text
								poster    = doc.search("//span[@class='postername']").text
								trip      = doc.search("//form/span[@class='postertrip']").text
								postid    = doc.search("//form/span/a[@class='quotejs'][2]").text
								reply     = doc.search("//form/blockquote[1]").inner_html.gsub("<br>", " ").gsub("<font class=\"unkfunc\">", "3").gsub("</font>", "").gsub(/<\/?[^>]*>/, "").gsub("&gt;", ">")
								image     = doc.search("//form/a[1]/@href").text
								date      = doc.search("//span[@class='posttime']").text

								subject = "\"#{subject}\" " if subject.length > 1
								reply = "| "+reply if reply.length > 1
								reply = reply[0..160]+" …" if reply.length > 160

								#date      = date[-17..-8] # Get the date from the file name
								#t         = date.to_i
								#da        = Time.at(t).strftime("%b %d %R")

								m.reply "%s3%s%s %s No.%s | File: %s %s" % [subject, poster, trip, date, postid, image, reply]
							end

						else # Board Index Title
							page = @agent.get(link)

							begin
								title = page.title.gsub(/\s+/, ' ').strip
							rescue
								title = "text/html"
							end

							uri = URI.parse(page.uri.to_s)
							m.reply "0,3Title %s (%s)" % [title, uri.host]
						end

					when "twitter.com"

						bang = link.split("/")
						begin
							if bang[5].include? "status"
								twurl = Nokogiri::XML(open("http://api.twitter.com/1/statuses/show.xml?id=#{bang[6]}&include_entities=false", :read_timeout=>3).read)

								tweettext   = twurl.xpath("//status/text").text.gsub(/\s+/, ' ')
								posted      = twurl.xpath("//status/created_at").text
								name        = twurl.xpath("//status/user/name").text
								screenname  = twurl.xpath("//status/user/screen_name").text

								time        = Time.parse(posted)
								time        = minutes_in_words(time)

								m.reply "12Twitter #{name} (@#{screenname}): #{tweettext} | Posted #{time}"
							elsif bang[4].include? "status"
								twurl = Nokogiri::XML(open("http://api.twitter.com/1/statuses/show.xml?id=#{bang[5]}&include_entities=false", :read_timeout=>3).read)

								tweettext   = twurl.xpath("//status/text").text.gsub(/\s+/, ' ')
								posted      = twurl.xpath("//status/created_at").text
								name        = twurl.xpath("//status/user/name").text
								screenname  = twurl.xpath("//status/user/screen_name").text

								time        = Time.parse(posted)
								time        = minutes_in_words(time)

								m.reply "12Twitter #{name} (@#{screenname}): #{tweettext} | Posted #{time}"
							else
								m.reply "0,3Title Twitter (twitter.com)"
							end
						rescue
							m.reply "0,3Title Twitter (twitter.com)"
						end

					else # Generic Title
						page = @agent.get(link)

						begin
							title = page.title.gsub(/\s+/, ' ').strip
						rescue
							title = "text/html"
						end

						uri = URI.parse(page.uri.to_s)
						m.reply "0,3Title %s (%s)" % [title, uri.host]
					end

				# File
				else
					return unless ignore_nick(m.user.nick).nil? and disable_passive_files(m.channel.name).nil?

					fileSize = page.header['content-length'].to_i

					case fileSize
						when 0..1024 then size = (fileSize.round(1)).to_s + " B"
						when 1025..1048576 then size = ((fileSize/1024.0).round(1)).to_s + " KB"
						when 1048577..1073741824 then size = ((fileSize/1024.0/1024.0).round(1)).to_s + " MB"
						else size = ((fileSize/1024.0/1024.0/1024.0).round(1)).to_s + " GB"
					end

					filename = ''

					if page.header['content-disposition']
						filename = page.header['content-disposition'].gsub("inline;", "").gsub("filename=", "").gsub(/\s+/, ' ') + " "
					end

					type = page.header['content-type']

					uri = URI.parse(page.uri.to_s)

					m.reply "0,3File %s%s %s (%s)" % [filename, type, size, uri.host]
				end

			rescue Mechanize::ResponseCodeError => ex
				m.reply "0,3Title #{ex.response_code} Error" 
			rescue
				nil
			end
		end
	end
end