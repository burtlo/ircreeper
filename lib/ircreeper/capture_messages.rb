require 'csv'

module Ircreeper
  class CaptureMessages
    include Cinch::Plugin

    listen_to :connect, method: :on_connect
    listen_to :channel, method: :on_channel

    def on_channel(m)
      seen = seen_object(m)

      record last_message: {
        time: seen.time,
        channel: seen.channel.name,
        user: seen.user,
        message: seen.message
      }

      append messages: {
        time: seen.time,
        channel: seen.channel.name,
        user: seen.user,
        message: seen.message
      }
    end

    def record(data)
      filename = "#{data.keys.first}.yml"
      File.write(filename,data.to_yaml)
    end

    def append(data)
      filename = "#{data.keys.first}.csv"
      headers = data.values.first.keys

      CSV.open(filename, "a", write_headers: true, headers: headers) do |csv|
        csv << data.values.first.values
      end
    end

    def seen_object(m)
      Seen.new(m.user.nick, m.channel, m.message, Time.now.utc)
    end

    class Seen < Struct.new(:user, :channel, :message, :time) ; end

  end
end