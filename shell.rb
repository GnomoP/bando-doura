#!/usr/bin/env ruby

require 'readline'
require './shell_commands'

class Shell
  include Commands

  def initialize bot, config
    @bot = bot
    @cfg = config
    @read = Readline
    @list = config["shell_commands"]

    user = bot.profile.name
    disc = bot.profile.discriminator
    @prompt = "(#{user}##{disc}) >> "

    @read.completion_append_character = " "
    @read.completion_proc = proc { |s| @read::HISTORY.grep(/^\S/) }

  end

  def loop
    while input = @read.readline(@prompt, true)

      @hist = @read::HISTORY
      @hist.pop and next if input == ""
      @hist.pop and next if input.match('^\s+$')

      begin
        eval(input)
      rescue Exception => e
        puts e.backtrace.join ""
        puts e.message
      else
        puts "Done."
      end

    end
  end

end