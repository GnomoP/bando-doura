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

  def log_event event
    server = event.server
    author = event.author
    channel = event.channel
    message = event.message
    time = Time.now
    name = "#{author.name}##{author.discriminator}"

    out = [
      "[#{time}]:",
      "    Author:  #{name} (#{author.id})",
      "    Server:  #{server.name} (#{server.id})",
      "    Channel: #{channel.name} (#{channel.id})",
      "    Message: #{message.id}",
      "    Content: #{message.content}",]
    File.open("./requests.log", "a+") do |f|
      f.puts out.join("\n")
    end
    puts "\nSuccessfuly replied to #{name} (#{server.id})"
  end

end

bot = CommandBot.new token: OPT["bot_token"], prefix: OPT["prefix"], client_id: OPT["client_id"]

bot.command :add do |event, *text|
  if event.channel.private?
    next "Muleque espertinho... (Sua frase **não** foi adicionada)"
  end

  text = text.join(' ')
  begin
    bot.add_quote(text)
    bot.log_event(event)
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  else
    "Acha que eu sou gado pra ficar me mamando? (Sua frase foi adicionada)"
  end
end

bot.command :ping do |event|
  mention = event.author.mention
  time = (Time.now - event.timestamp).round(6) * 1000

  bot.log_event(event) unless event.channel.private?
  "#{mention} Criança, não me enche o saco (#{time.round(3)}ms)"
end

bot.command :source do |event|
  bot.log_event(event) unless event.channel.private?
  OPT["source_repo"]
end

bot.command :invite do |event|
  bot.log_event(event) unless event.channel.private?
  event.bot.invite_url
end

bot.command :restart do |event|
  break unless event.user.id == OPT["bot_owner"]
  bot.log_event(event) unless event.channel.private?
  event.message.react(BYE)
  exit 0
end

bot.command :quit do |event|
  break unless event.user.id == OPT["bot_owner"]
  bot.log_event(event) unless event.channel.private?
  event.message.react(BYE)
  exit 1
end

bot.run :async

bot.message(contains: bot.bot_user.mention, private: false) do |event|
  begin
    event.respond(bot.pick_quote)
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  ensure
    bot.log_event(event)
  end
end

shell = Shell.new(bot, OPT)
shell.loop()