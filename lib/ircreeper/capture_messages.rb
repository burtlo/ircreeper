
module Ircreeper
  class CaptureMessages
    include Cinch::Plugin

    listen_to :connect, method: :on_connect
    listen_to :channel, method: :on_channel

    def users
      @users ||= {}
    end

    def on_connect(m)
      # no-operation
    end

    def on_channel(m)
      info "Logging channel message for #{m.user.nick}"
      seen = Seen.new(m.user.nick, m.channel, m.message, Time.new)
      users[m.user.nick] = seen
      save_message(seen)
    end

    def save_message(seen)
      File.open("messages.log","a") do |file|
        file.sync = true
        # TODO: the format should be a easily parseable
        file.puts "#{seen.time.utc} #{seen.who} #{seen.where} : #{seen.what}"
      end
    end

    class Seen < Struct.new(:who, :where, :what, :time)
      def to_s
        "[#{time.asctime}] #{who} was seen in #{where} saying #{what}"
      end
    end

  end
end