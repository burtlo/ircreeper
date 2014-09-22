require "ircreeper/version"
require 'cinch'
require 'cinch/logger/zcbot_logger'
require 'yaml'

module Ircreeper
  extend self

  class Seen < Struct.new(:who, :where, :what, :time)
    def to_s
      "[#{time.asctime}] #{who} was seen in #{where} saying #{what}"
    end
  end

  def start!

    bot = Cinch::Bot.new do

      configure do |c|
        c.server = "irc.freenode.org"
        c.channels = ["#metro"]
        c.nick = "irc_chef"
        # c.plugins.plugins = [UserCount]

      end

      log_file = File.open("pisg.log","a+")
      log_file.sync = true
      @loggers << Cinch::Logger::ZcbotLogger.new(log_file)

      on :connect do |m|
        # Connect and establish the data object that will store information
        @users ||= {}
      end

      on :channel do |m|
        info "Logging channel message for #{m.user.nick}"
        @users[m.user.nick] = Seen.new(m.user.nick, m.channel, m.message, Time.new)
      end

      on :join do |m|
        # Track the user

        # Take and store a new user count
        info "Watching a user for some information: #{m.user.nick}"
        current_list_of_users = bot.user_list.map {|u| u.nick }
        bot.store_users(current_list_of_users)
      end

      on :leaving do |m|
        # Stop tracking the user (look at :offline)
        # Take and store a new user count
        info "A user has left #{m.user.nick}, updating counts"
        current_list_of_users = bot.user_list.map {|u| u.nick }
        bot.store_users(current_list_of_users)
        # minus ourselves and ChanServ
      end

      def store_users(current_list_of_users)
        puts "USER COUNT: #{current_list_of_users} #{current_list_of_users.count}"
        data = { users: {
          count: current_list_of_users.count,
          time: Time.now.utc,
          users: current_list_of_users.to_yaml
        } }
        File.write("user_count.yml",data.to_yaml)
      end

    end

    bot.start

  end
end
