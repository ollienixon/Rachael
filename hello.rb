# encoding: utf-8

class Hello
  include Cinch::Plugin

  match /hi/
  def execute(m)
    begin
    #  url = Nokogiri::HTML(open("http://www.insultgenerator.org/").read)
    #  insult = url.xpath("//table/tr/td").text.strip
    #  m.reply "#{m.user.nick}: #{insult}"

      lines = Integer(%x(wc -l insult.txt)[/^\d+/])

      f = File.open('insult.txt')
      a = f.readlines
      m.reply "#{m.user.nick}: #{a[rand(lines)]}"
    rescue
      m.reply "#{m.user.nick}: Hi"
    end
  end
end