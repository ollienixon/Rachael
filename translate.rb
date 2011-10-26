# encoding: utf-8

class Translate
  include Cinch::Plugin

  match /t(?:r(?:anslate)?)? ([a-zA-Z-]{2,6}) ([a-zA-Z-]{2,6}) (.*)/u

  def execute(m, from, to, message)
    appId = ""

    begin
      url = open("http://api.microsofttranslator.com/V2/Ajax.svc/Translate?appId=#{appId}&from=#{from}&to=#{to}&text=#{CGI.escape(message)}").read
      url = url[1..url.length] # cut off some weird character at the start of the string
      text = "[#{from}=>#{to}] #{url}"
    rescue
      text = "Error"
    end
    m.reply "11Translate #{text}"
  end
end