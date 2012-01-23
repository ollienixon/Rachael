# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Green
	include Cinch::Plugin
	react_on :channel

	listen_to :channel
	def listen(m)
		return unless ignore_nick(m.user.nick).nil? and disable_passive(m.channel.name).nil?

		if m.message.match(/^3>/)
			begin
				new = GreenText.new(:text => m.message)
				new.save

				randomGreen = GreenText.get(1+rand(GreenText.count))
				m.reply randomGreen.text
			rescue
				nil
			end
		end
	end
end