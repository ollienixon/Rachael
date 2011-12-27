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



  # Ignore users

	match /set ignore (.+)/, method: :set_ignore
	def set_ignore(m, username)
		return unless check_admin(m.user)

		begin
			old = IgnoreDB.first(:nick => username.downcase)
			old.destroy! unless old.nil?

			new = IgnoreDB.new(:nick => username.downcase)
			new.save

			m.reply "I never liked him anyway"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 

	match /set unignore (.+)/, method: :set_unignore
	def set_unignore(m, username)
		return unless check_admin(m.user)

		begin
			old = IgnoreDB.first(:nick => username.downcase)
			old.destroy! unless old.nil?

			m.reply "Sorry about that"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end



  # Make/Remove admins

	match /set admin add (.+)/, method: :set_admin
	def set_admin(m, username)
		return unless check_admin(m.user)

		begin
			old = AdminDB.first(:nick => username.downcase)
			old.destroy! unless old.nil?

			new = AdminDB.new(:nick => username.downcase)
			new.save

			m.reply "A new master!"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 

	match /set admin del (.+)/, method: :set_del_admin
	def set_deladmin(m, username)
		return unless check_admin(m.user) and m.user.nick.downcase == $OWNER # Only the owner can remove admins

		begin
			old = AdminDB.first(:nick => username.downcase)
			old.destroy! unless old.nil?

			m.reply "I never liked him anyway"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end



  # URI ON/OFF

	match /set passive on (.+)/, method: :set_passive_on
	def set_passive_on(m, channel)
		return unless check_admin(m.user)

		begin
			old = PassiveDB.first(:channel => channel.downcase)
			old.destroy! unless old.nil?

			m.reply "Now reacting to URIs"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /set passive off (.+)/, method: :set_passive_off
	def set_passive_off(m, channel)
		return unless check_admin(m.user)

		begin
			old = PassiveDB.first(:channel => channel.downcase)
			old.destroy! unless old.nil?

			new = PassiveDB.new(:channel => channel.downcase)
			new.save

			m.reply "No longer reacting to URIs"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end



  # Join/Part channels

	match /join (.+)/, method: :join
	def join(m, channel)
		return unless check_admin(m.user)

		begin
			old = JoinDB.first(:channel => channel.downcase)
			old.destroy! unless old.nil?

			new = JoinDB.new(:channel => channel.downcase)
			new.save

			Channel(channel).join
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /part(?: (.+))?/, method: :part
	def part(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel

		begin
			old = JoinDB.first(:channel => channel.downcase)
			old.destroy! unless old.nil?

			Channel(channel).part if channel
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

end