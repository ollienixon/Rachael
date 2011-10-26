# encoding: utf-8

class UrbanDictionary
  include Cinch::Plugin

  match /u(?:r(?:ban)?)? (?:([1-7]{1}) )?(.+)/, method: :urban

  def urban(m, number, word)
    begin
      number ||= 1

      url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
      urban = Nokogiri::HTML(open(url))
      define = urban.search("//div[@class='definition']")[number.to_i-1].text.gsub(/\s+/, ' ')
      define = define[0..255]+"…" if define.length > 255
      reply = "#{word}: #{define}"

    rescue
      reply = "Error getting definition for '#{word}'"
    end
    m.reply "06UrbanDictionary #{reply}"
  end

end