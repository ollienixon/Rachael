# encoding: utf-8

class Bing
	include Cinch::Plugin

	match /b(?:ing)? (.+)/i
	match /g (.+)/i

	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?
		begin

			@bitly = Bitly.new($BITLYUSER, $BITLYAPI)

			@url = open("http://api.bing.net/xml.aspx?AppId=#{$BINGAPI}&Version=2.2&Market=en-US&Query=#{URI.escape(query)}&Sources=web&Web.Count=1")
			@url = Nokogiri::XML(@url)

			title      = @url.xpath("//web:WebResult[1]/web:Title", {"web" => "http://schemas.microsoft.com/LiveSearch/2008/04/XML/web"}).text
			desc       = @url.xpath("//web:WebResult[1]/web:Description", {"web" => "http://schemas.microsoft.com/LiveSearch/2008/04/XML/web"}).text
			url        = @url.xpath("//web:WebResult[1]/web:Url", {"web" => "http://schemas.microsoft.com/LiveSearch/2008/04/XML/web"}).text
			cache      = @url.xpath("//web:WebResult[1]/web:CacheUrl", {"web" => "http://schemas.microsoft.com/LiveSearch/2008/04/XML/web"}).text

			cache = @bitly.shorten(cache)
			more  = @bitly.shorten("http://www.bing.com/search?q=#{URI.escape(query)}")

			m.reply "2,0Bing %s > %s | Cached: %s; More results: %s" % [title, url, cache.shorten, more.shorten]
			m.reply "2,0Bing #{desc}" if desc.length > 1
		rescue
			m.reply "2,0Bing Error"
		end
	end
end