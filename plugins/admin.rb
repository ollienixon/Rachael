# encoding: utf-8

class Admin
  include Cinch::Plugin

	prefix lambda{ |m| m.bot.nick + ": " }


	match /nick (.+)/, method: :nick
	def nick(m, name)
		return unless check_admin(m.user)
		@bot.nick = name
	end


	match /quit(?: (.+))?/, method: :quit
	def quit(m, msg)
		return unless check_admin(m.user)
		bot.quit(msg)
	end


	match /msg (.+?) (.+)/, method: :message
	def message(m, who, text)
		return unless check_admin(m.user)
		User(who).send text
	end


	match /say (.+?) (.+)/, method: :message_channel
	def message_channel(m, chan, text)
		return unless check_admin(m.user)
		Channel(chan).send text
	end

	match /kick (.+)/, method: :kick
	def kick(m, nick)
		return unless check_admin(m.user)
		m.channel.kick(nick, "Get out.")
	end

	match /kickban (.+)/, method: :kickban
	def kickban(m, nick)
		return unless check_admin(m.user)
		baddie = User(nick);
		m.channel.ban(baddie.mask("*!*@%h"));
		m.channel.kick(nick, "4(USER WAS BEHEADED FOR THIS POST)")
	end


  # Ignore users

	match /ignore (.+)/, method: :set_ignore
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

	match /unignore (.+)/, method: :set_unignore
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

	match /list ignores/, method: :list_ignores
	def list_ignores(m)
		return unless check_admin(m.user)
		begin
			agent = Mechanize.new
			rows = ""

			IgnoreDB.all.each do |item|
				rows = rows + item.id.to_s + ". " + item.nick + "\n"
			end

			page = agent.get "http://p.sjis.me/"
			form = page.forms.first
			form.content = rows
			page = agent.submit form

			m.reply page.search("//a[@name='plain']/@href").text, true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 


  # Make/Remove admins

	match /add admin (.+)/, method: :set_admin
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

	match /remove admin (.+)/, method: :set_del_admin
	def set_deladmin(m, username)
		return unless check_admin(m.user) and m.user.nick.downcase == $OWNER

		begin
			old = AdminDB.first(:nick => username.downcase)
			old.destroy! unless old.nil?

			m.reply "I never liked him anyway"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /list admins/, method: :list_admins
	def list_admins(m)
		return unless check_admin(m.user)
		begin
			agent = Mechanize.new
			rows = ""

			AdminDB.all.each do |item|
				rows = rows + item.id.to_s + ". " + item.nick + "\n"
			end

			page = agent.get "http://p.sjis.me/"
			form = page.forms.first
			form.content = rows
			page = agent.submit form

			m.reply page.search("//a[@name='plain']/@href").text, true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end


  # URI ON/OFF

	match /passive on(?: (.+))?/, method: :set_passive_on
	def set_passive_on(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel

		begin
			old = PassiveDB.first(:channel => channel.downcase)
			old.destroy! unless old.nil?

			m.reply "Now reacting to URIs"
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end

	match /passive off(?: (.+))?/, method: :set_passive_off
	def set_passive_off(m, channel)
		return unless check_admin(m.user)
		channel ||= m.channel

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

	match /list channels/, method: :list_channels
	def list_channels(m)
		return unless check_admin(m.user)
		begin
			agent = Mechanize.new
			rows = ""

			JoinDB.all.each do |item|
				rows = rows + item.id.to_s + ". " + item.channel + "\n"
			end

			page = agent.get "http://p.sjis.me/"
			form = page.forms.first
			form.content = rows
			page = agent.submit form

			m.reply page.search("//a[@name='plain']/@href").text, true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 


	# Last.fm 

	match /list lastfm/, method: :list_lastfm
	def list_lastfm(m)
		return unless check_admin(m.user)
		begin
			agent = Mechanize.new
			rows = ""

			LastfmDB.all.each do |item|
				rows = rows + item.id.to_s + ". " + item.nick + " = " + item.username + "\n"
			end

			page = agent.get "http://p.sjis.me/"
			form = page.forms.first
			form.content = rows
			page = agent.submit form

			m.reply page.search("//a[@name='plain']/@href").text, true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end 

	match /del lastfm (\d+)/, method: :del_lastfm
	def del_lastfm(m, number)
		return unless check_admin(m.user)
		begin
			old = LastfmDB.first(:id => number.to_i)
			old.destroy! unless old.nil?

			m.reply "Done", true
		rescue
			m.reply "Oops something went wrong", true
			raise
		end
	end


end