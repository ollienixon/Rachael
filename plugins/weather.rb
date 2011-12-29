# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Weather
	include Cinch::Plugin

	# Check the DB for stored locations

	def get_location(m, param) 
		if param == '' || param.nil?
			location = LocationDB.first(:nick => m.user.nick.downcase)
			if location.nil?
				m.reply "location not provided nor on file."
				return nil
			else
				return location.location
			end
		else
			return param.strip
		end
	end 


	match /w(?:e(?:ather)?)?(?: (.+))?$/, method: :weather
	def weather(m, loc = nil)
		return unless ignore_nick(m.user.nick).nil?

		location = get_location(m, loc)
		return if location.nil?

		begin
			argument = URI.escape(location)
			url = Nokogiri::XML(open("http://www.google.com/ig/api?weather=#{argument}").read)
			url.encoding = 'utf-8'

			city        = url.xpath("//forecast_information/city/@data")
			condition   = url.xpath("//current_conditions/condition/@data")
			tempc       = url.xpath("//current_conditions/temp_c/@data")
			tempf       = url.xpath("//current_conditions/temp_f/@data")
			humidity    = url.xpath("//current_conditions/humidity/@data")
			wind        = url.xpath("//current_conditions/wind_condition/@data")

			city        = Iconv.conv("UTF-8", 'ISO-8859-1', city.to_s)

			return unless city.length > 1

			text = "#{city}: #{condition} #{tempc}°C/#{tempf}°F. #{humidity}. #{wind}"

		rescue 
			m.reply "Error getting weather for #{loc}"
		end
		m.reply "0,2Weather #{text}"
	end

	match /f(?:o(?:recast)?)?(?: (.+))?$/, method: :forecast
	def forecast(m, loc = nil)
		return unless ignore_nick(m.user.nick).nil?

		location = get_location(m, loc)
		return if location.nil?

		begin
			argument = URI.escape(location)
			url = Nokogiri::XML(open("http://www.google.com/ig/api?weather=#{argument}").read)
			url.encoding = 'utf-8'

			forecast  = url.xpath("//forecast_conditions")
			city      = url.xpath("//forecast_information/city/@data")
			city      = Iconv.conv("UTF-8", 'ISO-8859-1', city.to_s)
			text      = "#{city}: "

			return unless city.length > 1

			forecast.each do |cond|
				day         = cond.xpath("day_of_week/@data")
				condition   = cond.xpath("condition/@data")

				high        = cond.xpath("high/@data")
				low         = cond.xpath("low/@data")

				highC       = (("#{high}".to_i)-32.0)*(5.0/9.0)
				lowC        = (("#{low}".to_i)-32.0)*(5.0/9.0)

				text = text + "#{day}: #{condition} #{highC.round}°C/#{lowC.round}°C (#{high}°F/#{low}°F) | "
			end
			text = text[0..text.length-4]
		rescue 
			text = "Error getting forecast for #{loc}"
		end
		m.reply "0,2Forecast #{text}"
	end
end