#!/usr/bin/env ruby

require 'discordrb'
require 'json'
require './shell'

OK = "\U1F44C"
BYE = "\U1F44B"

NO = "\u274E".freeze
YES = "\u2705".freeze

File.open(ARGV[0] || "./config.json", "r+") do |f|
  f.write("{\n  \n}") if f.read.empty?

  f.seek 0
  CONFIG = JSON.parse(f.read)
end

File.open("./help.json", "r+") do |f|
  f.write("{\n  \n}") if f.read.empty?

  f.seek 0
  HELP = JSON.parse(f.read).map do |k1, v1|
    k1 = k1.to_sym
    v1 = v1.map { |k2, v2| [k2.to_sym, v2] }.to_h
    [k1, v1]
  end.to_h
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
    server = event.server
    channel = event.channel
    message = event.message

    time = Time.now
    name = "#{author.name}##{author.discriminator}"

    out = [
      "[#{time}]:",
      "    Message: #{message.id}",
      "    Content: #{message.content}",]

    if channel.private?

      if author.id == CONFIG["client_id"]
        author = event.channel.recipient
        name = "#{author.name}##{author.discriminator}"
        out.insert(1, "  Recipient: #{name} (#{author.id})")
      else
        out.insert(1, "    Sender:  #{name} (#{author.id})")
      end

    elsif channel.group?

      if author.id == CONFIG["client_id"]
        out.insert(1, "      Group: #{channel.name} (#{channel.id})")
      else
        out.insert(1, "     Author: #{name} (#{author.id})")
        out.insert(2, "      Group: #{channel.name} (#{channel.id})")
      end

    elsif server

      out.insert(1, "     Author: #{name} (#{author.id})")
      out.insert(2, "     Server: #{server.name} (#{server.id})")
      out.insert(2, "    Channel: #{channel.name} (#{channel.id})")

    end

    File.open("./requests.log", "a+") do |f|
      f.puts out.join("\n")
    end

  end

  def add_prefix id, prefix

    begin
      prefixes = File.read("./prefixes.json")
      prefixes = JSON.parse(prefixes)

      prefixes[id.to_s] = prefix

      File.open("./prefixes.json", "w") do |f|
        f.puts(JSON.pretty_generate(prefixes))
      end
    rescue Exception => e
      puts e.backtrace.join ""
      puts e.message
    end

  end

  def get_prefixes

    File.open("./prefixes.json", "r+") do |f|
      f.write("{\n  \n}") if f.read.empty?

      f.seek 0
      JSON.parse(f.read)
    end

  end

end

prefix_proc = proc do |message|
  prefixes = File.open("./prefixes.json", "r+") do |f|
    f.write("{\n  \n}") if f.read.empty?

    f.seek 0
    JSON.parse(f.read)
  end

  id = message.channel.server.id rescue message.channel.id
  prefix = prefixes[id.to_s]  || CONFIG["prefix"]

  message.content[prefix.size .. -1] if message.content.start_with? prefix
end

OPT = {
  :token => CONFIG["bot_token"],
  :client_id => CONFIG["client_id"],
  :prefix => prefix_proc,
  :parse_self => true
}

bot = CommandBot.new OPT

bot.command :add, HELP[:add] do |event, *text|
  bot.log_event(event) unless event.channel.private?

  if event.channel.private? and event.author.id != CONFIG["bot_owner"]
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

bot.command :say, HELP[:say] do |event, *text|
  break unless event.user.id == CONFIG["bot_owner"]
  bot.log_event(event) unless event.channel.private?
  event.message.delete() rescue puts "Couldn't delete message"
  text.join(' ')
end

bot.command :ping, HELP[:ping] do |event|
  mention = event.author.mention
  time = (Time.now - event.timestamp).round(6) * 1000

  bot.log_event(event) unless event.channel.private?
  "#{mention} Criança, não me enche o saco (#{time.round(3)}ms)"
end

bot.command :prefix, HELP[:prefix] do |event, *text|
  text = text.join(' ')

  if event.server
    permission = event.user.permission?(:administrator, event.channel)
    unless permission || event.user.id == CONFIG["bot_owner"]
      next "Apenas administradores podem mudar o prefixo do servidor."
    end
  end

  id = event.server.id rescue event.channel.id
  prefix = bot.get_prefixes()[id]

  prefix = CONFIG["prefix"] unless prefix
  next "Prefixo atual: \"#{prefix}\". Use `#{prefix}prefix Novo Prefixo` para alterá-lo." if text.empty?

  bot.add_prefix(id, text)
  "Prefixo alterado: de \"#{prefix}\" para \"#{text}\""
end

bot.command :source, HELP[:source] do |event|
  bot.log_event(event) unless event.channel.private?
  CONFIG["source_repo"]
end

bot.command :invite, HELP[:invite] do |event|
  bot.log_event(event) unless event.channel.private?
  event.bot.invite_url
end

bot.command :restart, HELP[:restart] do |event|
  break unless event.user.id == CONFIG["bot_owner"]
  bot.log_event(event) unless event.channel.private?
  event.message.react(BYE) rescue nil
  exit 0
end

bot.command :quit, HELP[:quit] do |event|
  break unless event.user.id == CONFIG["bot_owner"]
  bot.log_event(event) unless event.channel.private?
  event.message.react(BYE) rescue nil
  exit 1
end

bot.run :async

bot.ready do |event|
  sleep(10) and bot.game = CONFIG["game_status"]
end

bot.mention contains: /prefixo?/i do |event|
  begin
    id = event.server.id rescue event.channel.id
    prefix = bot.get_prefixes()[id] || "-"

    event << "Prefixo atual: \"#{prefix}\". Use `#{prefix}prefix Novo Prefixo` para alterá-lo."
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  ensure
    bot.log_event(event) unless event.channel.private?
  end
end

bot.mention contains: not!(/prefixo?/i) do |event|
  begin
    event << bot.pick_quote
  rescue Exception => e
    puts e.backtrace.join ""
    puts e.message
  ensure
    bot.log_event(event) unless event.channel.private?
  end
end

bot.private_message do |event|
  bot.log_event(event)
end

bot.message from: bot.profile, private: false do |event|
  bot.log_event(event)
end

shell = Shell.new(bot, CONFIG)
shell.loop()
