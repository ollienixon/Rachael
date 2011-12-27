# encoding: utf-8

class Insult
	include Cinch::Plugin

	match /insult$/, method: :hey
	match /insult (.+)/, method: :hey_faggot

	def hey(m)
		return unless ignore_nick(m.user.nick).nil?

		begin
			lines = Integer(%x(wc -l insult.txt)[/^\d+/])

			f = File.open('insult.txt')
			a = f.readlines
			m.reply a[rand(lines)], true
		rescue
			m.reply "Hi", true
		end
	end

	def hey_faggot(m, person)
		return unless ignore_nick(m.user.nick).nil?

		begin
			lines = Integer(%x(wc -l insult.txt)[/^\d+/])

			f = File.open('insult.txt')
			a = f.readlines
			m.reply "#{person}: #{a[rand(lines)]}"
		rescue
			m.reply "#{person}: Hi"
		end
	end
end