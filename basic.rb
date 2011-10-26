class Basic
  include Cinch::Plugin

  $botnick = "Rachael"
  $nickservpassword = ""

  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part
  match /quit(?: (.+))?/, method: :quit
  match /help/, method: :help
  match /nick (.+)/, method: :nick

  # Set bot admins
  def initialize(*args)
    super
    @admins = ["qb", "qb2"]
  end

  def check_user(user)
    user.refresh # be sure to refresh the data, or someone could steal the nick
    @admins.include?(user.authname)
  end

  # Identify with Nickserv then join channels
  listen_to :connect, method: :identify
  def identify(m)
    User("nickserv").send("identify #{$nickservpassword}")
    sleep 1 # Make sure the vhost kicks in before joining a channel
    Channel("#/tv/shows").join
    Channel("#DEVELOPERS").join
    Channel("#kpop").join
    Channel("#touhouradio").join
  end

  # Rename when nick becomes available
  listen_to :quit, method: :rename
  def rename(m)
    if m.user.nick == $botnick
    	@bot.nick = $botnick
    	User("nickserv").send("identify #{$nickservpassword}")
    end
  end

  # Rejoin channel if kicked
  listen_to :kick
  def listen(m)
    return unless m.params[1] == @bot.nick
    sleep config[:delay] || 2
    Channel(m.channel.name).join(m.channel.key)
  end


  # :nick [name]
  def nick(m, name)
    return unless check_user(m.user)
    @bot.nick = name
  end


  # :join [channel]
  def join(m, channel)
    return unless check_user(m.user)
    Channel(channel).join
  end

  # :part [channel]
  def part(m, channel)
    return unless check_user(m.user)
    channel ||= m.channel
    Channel(channel).part if channel
  end

  # :quit
  def quit(m, msg)
    return unless check_user(m.user)
    bot.quit(msg)
  end

  # :help
  def help(m)
    m.reply "#{m.user.nick}: http://sjis.me/help.html"
  end

end