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
    author = event.author
    channel = event.channel
    message = event.message

    time = Time.now
    name = "#{author.name}##{author.discriminator}"

    out = [
      "[#{time}]:",
      "    Message: #{message.id}",
      "    Content: #{message.content}",]

    if channel.private?
      out.insert(1, "    Sender:  #{name} (#{author.id})")
    else
      server = event.server
      out.insert(1, "    Author:  #{name} (#{author.id})")
      out.insert(2, "    Server:  #{server.name} (#{server.id})")
      out.insert(2, "    Channel: #{channel.name} (#{channel.id})")
    end

    File.open("./requests.log", "a+") do |f|
      f.puts out.join("\n")
    end
  end

end

bot = CommandBot.new token: OPT["bot_token"], prefix: OPT["prefix"], client_id: OPT["client_id"], parse_self: true

bot.command :add do |event, *text|
  bot.log_event(event)

  if event.channel.private? and event.author.id != OPT["bot_owner"]
    next "Muleque espertinho... (Sua frase **não** foi adicionada)"
  end

  text = text.join(' ')
  begin
    bot.add_quote(text)
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  else
    "Acha que eu sou gado pra ficar me mamando? (Sua frase foi adicionada)"
  end
end

bot.command :say do |event, *text|
  break unless event.user.id == OPT["bot_owner"]
  bot.log_event(event)
  event.message.delete() rescue nil
  text.join(' ')
end

bot.command :ping do |event|
  mention = event.author.mention
  time = (Time.now - event.timestamp).round(6) * 1000

  bot.log_event(event)
  "#{mention} Criança, não me enche o saco (#{time.round(3)}ms)"
end

bot.command :source do |event|
  bot.log_event(event)
  OPT["source_repo"]
end

bot.command :purge do |event, quant=100, *condition|
  break if event.user.id != OPT["bot_owner"] or event.channel.private?
  bot.log_event(event)

  quant = Integer(quant) rescue 50

  history = event.channel.history(quant).select do |m|
    unless condition.empty?
      m.author.id == bot.profile.id
    else
      eval(condition.join(' '))
    end
  end

  if history.length < 2 or history.length > 100
    next "Can only delete between 2 and 100 messages!"
  end

  event.channel.delete_messages(history, false)
end

bot.command :invite do |event|
  bot.log_event(event)
  event.bot.invite_url
end

bot.command :restart do |event|
  break unless event.user.id == OPT["bot_owner"]
  bot.log_event(event)
  event.message.react(BYE) rescue nil
  exit 0
end

bot.command :quit do |event|
  break unless event.user.id == OPT["bot_owner"]
  bot.log_event(event)
  event.message.react(BYE) rescue nil
  exit 1
end

bot.run :async

bot.mention() do |event|
  begin
    event.respond(bot.pick_quote)
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  ensure
    bot.log_event(event)
  end
end

bot.private_message() do |event|
  next if event.author.id == bot.profile.id
  bot.log_event(event)
end

bot.message(from: bot.profile, private: false) { |event| bot.log_event(event) }
bot.ready() { |event| bot.update_status("online", { :game => OPT["game_status"] }, 0, false) }

shell = Shell.new(bot, OPT)
shell.loop()
