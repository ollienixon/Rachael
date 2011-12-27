# encoding: utf-8

class Twitter
	include Cinch::Plugin

	match /tw(?:itter)? (.+)/

	def minutes_in_words(timestamp)
		minutes = (((Time.now - timestamp).abs)/60).round

		return nil if minutes < 0

		case minutes
		when 0..4            then '5 minutes'
		when 5..14           then '15 minutes'
		when 15..29          then '30 minutes'
		when 30..59          then '30 minutes'
		when 60..1439        
			words = (minutes/60)
			if words > 1
				"#{words.to_s} hours"
			else
				"#{words.to_s} hour"
			end
		when 1440..11519     
			words = (minutes/1440)
			if words > 1
				"#{words.to_s} days"
			else
				"#{words.to_s} day"
			end
		when 11520..43199    
			words = (minutes/11520)
			if words > 1
				"#{words.to_s} weeks"
			else
				"#{words.to_s} week"
			end
		when 43200..525599   
			words = (minutes/43200)
			if words > 1
				"#{words.to_s} months"
			else
				"#{words.to_s} month"
			end
		else                      
			words = (minutes/525600)
			if words > 1
				"#{words.to_s} years"
			else
				"#{words.to_s} year"
			end
		end
	end

	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?

		begin
			url = Nokogiri::XML(open("http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{query}&count=1&include_rts=true&exclude_replies=true", :read_timeout=>3).read)

			tweettext   = url.xpath("//status/text").text.gsub(/\s+/, ' ')
			posted      = url.xpath("//status/created_at").text
			name        = url.xpath("//statuses/status/user/name").text
			screenname  = url.xpath("//statuses/status/user/screen_name").text

			time        = Time.parse(posted)
			time        = minutes_in_words(time)

			m.reply "12Twitter #{name} (@#{screenname}): #{tweettext} | Posted #{time} ago"
		rescue Timeout::Error
			m.reply "12Twitter Timeout Error. Maybe twitter is down?"
		rescue
			m.reply "12Twitter Error getting tweet for #{query}"
		end
	end
end