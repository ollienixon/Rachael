# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Weather
  include Cinch::Plugin

  match /w(?:e(?:ather)?)? (.+)/, method: :weather
  match /f(?:o(?:recast)?)? (.+)/, method: :forecast

  def weather(m, loc)
    begin
      argument = URI.escape(loc)
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

  def forecast(m, loc)
    begin
      argument = URI.escape(loc)
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

        text = text + "#{day}: #{condition} #{high}°F/#{low}°F | "
      end
      text = text[0..text.length-4]
    rescue 
      text = "Error getting forecast for #{loc}"
    end
    m.reply "0,2Forecast #{text}"
  end
end