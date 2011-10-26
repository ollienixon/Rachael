# encoding: utf-8

class Pick
  include Cinch::Plugin

  match /r(?:and)? (.+)/
  def execute(m, query)
    begin
      options = query.split(/\|/)
      m.reply "#{m.user.nick}: #{options[rand(options.length)]}"
    rescue
      nil
    end
  end
end