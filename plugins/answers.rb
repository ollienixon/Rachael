# encoding: utf-8

class Answers
	include Cinch::Plugin

	match /a(?:nswer)? (.+)/

	def execute(m, query)
		return unless ignore_nick(m.user.nick).nil?
		begin

			@bitly = Bitly.new($BITLYUSER, $BITLYAPI)
			 
			@url = open("http://api.wolframalpha.com/v2/query?appid=#{$WOLFRAMAPI}&input=#{URI.escape(query)}")
			@url = Nokogiri::XML(@url)

			input     = @url.xpath("//pod[@id='Input']/subpod/plaintext").text.gsub(/\s+/, ' ')
			output    = @url.xpath("//pod[@id='Result']/subpod/plaintext").text.gsub(/\s+/, ' ')

			input  = input[0..140]+"..."  if input.length > 140
			output = output[0..140]+"..." if output.length > 140
			output = "┐('～`；)┌ ..." if output.length < 1

			more  = @bitly.shorten("http://www.wolframalpha.com/input/?i=#{URI.escape(query)}")

			m.reply "7Wolfram %s => %s | More info: %s" % [input, output, more.shorten]
		rescue
			m.reply "7Wolfram Error"
		end
	end
end