#!/usr/bin/env ruby

require 'discordrb'
require 'json'
require './shell'

OK = "\U1F44C".freeze
BYE = "\U1F44B".freeze

if ARGV[0]
  fp = ARGV[0]
else
  fp = "./config.json"
end

File.open(fp, "r+") do |f|
  if f.read.empty?
    default = ['{', '  "client_id": "",', '  "bot_token": ""', '}']
    f.write(default.join "\n")
  end

  f.seek 0
  OPT = JSON.parse(f.read)
end

class CommandBot < Discordrb::Commands::CommandBot
  def pick_quote

    begin
      quotes = File.read("./quotes.json")
      quotes = JSON.parse(quotes)["frases"]
      raise unless quotes.any?
    rescue Exception => e
      puts e.backtrace.join ""
      puts e.message
      "Manutenção sempre é foda nesse país..."
    else
      quotes.sample
    end

  end

  def add_quote quote

    begin
      quotes = File.read("./quotes.json")
      quotes = JSON.parse(quotes)["frases"] << quote

      File.open("./quotes.json", "w") do |f|
        f.puts(JSON.pretty_generate({"frases" => quotes}))
      end
    rescue Exception => e
      puts e.backtrace.join ""
      puts e.message
    end

  end

end

bot = CommandBot.new token: OPT["bot_token"], prefix: OPT["prefix"], client_id: OPT["client_id"]

bot.command :add do |event, *text|
  text = text.join(' ')
  begin
    bot.add_quote(text) and next
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  else
    "Acha que eu sou gado pra ficar me ordenando?"
  end
end

bot.command :ping do |event|
  mention = event.author.mention
  time = (Time.now - event.timestamp).round(6) * 1000
  "#{mention} Criança, não me enche o saco (#{time.round(3)}ms)"
end

bot.command :source do |event|
  OPT["source_repo"]
end

bot.command :invite do |event|
  event.bot.invite_url
end

bot.command :restart do |event|
  break unless event.user.id == OPT["bot_owner"]

  event.message.react(BYE)
  exit 0
end

bot.command :quit do |event|
  break unless event.user.id == OPT["bot_owner"]

  event.message.react(BYE)
  exit 1
end

bot.run :async

bot.message(contains: bot.bot_user.mention, private: false) do |event|
  begin
    event.respond(bot.pick_quote)
    name = event.user.name
    disc = event.user.discriminator
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  else
    puts "\nSuccessfuly replied to #{name}##{disc}"
  end
end

shell = Shell.new(bot, OPT)
shell.loop()