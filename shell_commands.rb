#!/usr/bin/env

module Commands

def send id = @cfg["bot_owner"], say = nil
  id = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue id
  @bot.send_message(id, say || @bot.pick_quote())
end

def purge id = @cfg["bot_owner"], quant = 50, condition = nil
  channel = @bot.pm_channel(id) rescue nil
  return unless channel

  history = event.channel.history(quant).select do |m|
    unless condition
      m.author.id == bot.profile.id
    else
      eval(condition.join(' '))
    end
  end

  if history.length < 2 or history.length > 100
    puts "Can only delete between 2 and 100 messages!"
    return
  end

  channel.delete_messages(history, false)
end

def read id = @cfg["bot_owner"], quant = 10
  channel = @bot.pm_channel(id) if @bot.pm_channel(id) rescue nil
  channel ||= @bot.channel(id)
  channel.history(quant).reverse_each do |m|
    next if m.content == ""
    next if m.content =~ /^\s+$/m

    puts "\r#{m.author.name}: #{m.content}"
  end
end

def push commit = "Version bump"
  system("./push.sh \"#{commit}\"")
end

alias_method :ping, :send

end