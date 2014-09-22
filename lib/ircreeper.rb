require "ircreeper/version"
require 'cinch'
require 'cinch/logger/zcbot_logger'
require 'yaml'

require 'ircreeper/user_count'
require 'ircreeper/capture_messages'

module Ircreeper
  extend self

  def start!

    bot = Cinch::Bot.new do

      configure do |c|
        c.server = "irc.freenode.org"
        c.channels = ["#chef"]
        c.nick = "irc_chef"
        c.plugins.plugins = [UserCount,CaptureMessages]

      end

      log_file = File.open("pisg.log","a+")
      log_file.sync = true
      @loggers << Cinch::Logger::ZcbotLogger.new(log_file)

    end

    bot.start

  end
end
