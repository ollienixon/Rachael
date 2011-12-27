# encoding: utf-8

class Translate
	include Cinch::Plugin

	match /t(?:r(?:anslate)?)? ([a-zA-Z-]{2,6}) ([a-zA-Z-]{2,6}) (.*)/u

	def execute(m, from, to, message)
		return unless ignore_nick(m.user.nick).nil?

		begin
			url = open("http://api.microsofttranslator.com/V2/Ajax.svc/Translate?appId=#{$BINGAPI}&from=#{from}&to=#{to}&text=#{CGI.escape(message)}").read
			url = url[1..url.length] # cut off some weird character at the start of the string
			m.reply "11Translate [#{from}=>#{to}] #{url}"
		rescue
			m.reply "11Translate Error"
		end
	end
end