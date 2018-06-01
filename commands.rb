#!/usr/bin/env

module Commands

def send id: @cfg["commands_channel"], say: nil
  id = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue id
  @bot.send_message(id, say || @bot.pick_quote())
end

def purge id: @cfg["commands_channel"], quant: 100
  channel = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue nil
  channel ||= @bot.channel(id)

  channel.delete_messages(channel.history(quant))
end

def push commit = "Version bump"
  system("./push.sh \"#{commit}\"")
end

def read id = @cfg["commands_channel"], quant = 10
  channel = @bot.pm_channel(id) if @bot.pm_channel(id) rescue nil
  channel ||= @bot.channel(id)
  channel.history(quant).reverse_each do |m|
    next if m.content == ""
    next if m.content =~ /^\s+$/m

    puts "\r#{m.author.name}: #{m.content}"
  end
end

end