# encoding: utf-8

class UserSet
  include Cinch::Plugin


	# Last.fm username

	match /set lastfm (.+)/, method: :set_lastfm
	def set_lastfm(m, username)
		return unless ignore_nick(m.user.nick).nil?
		begin
			old = LastfmDB.first(:nick => m.user.nick.downcase)
			old.destroy! unless old.nil?

			new = LastfmDB.new(
				:nick => m.user.nick.downcase,
				:username => username.downcase
			)
			new.save

			m.reply "last.fm user updated to: #{username}", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 

end