# encoding: utf-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

class Green
	include Cinch::Plugin
	react_on :channel

	listen_to :channel
	def listen(m)
		return unless ignore_nick(m.user.nick).nil? 

		if m.message.match(/^0?3>/)
			begin
				return unless m.message.length < 141

				message = m.message.gsub(/\x1f|\x02|\x12|\x0f|\x16|\x03(?:\d{1,2}(?:,\d{1,2})?)?/, '')

				new = GreenText.new(:text => message)
				new.save

				return unless disable_passive(m.channel.name).nil?

				randomGreen = GreenText.get(1+rand(GreenText.count))
				m.reply "3#{randomGreen.text}"
			rescue
				nil
			end
		end
	end
end