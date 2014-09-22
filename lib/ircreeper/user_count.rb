
module Ircreeper
class UserCount
    include Cinch::Plugin

    listen_to :join, method: :on_join
    listen_to :leaving, method: :on_leaving

    def current_users
      bot.user_list.map {|u| u.nick }
    end

    def on_join(m)
      # TODO: Need to filter per channel
      append users: {
        time: Time.now.utc,
        channel: m.channel.name,
        user: m.user.nick,
        action: "join"
      }

      # TODO: Need to filter per channel
      record current_users: {
        count: current_users.count,
        users: current_users,
        time: Time.now.utc
      }

    end

    def on_leaving(m,user)
      # TODO: Need to filter per channel
      append users: {
        user: m.user.nick,
        channel: m.channel.name,
        time: Time.now.utc,
        action: "leaving"
      }

      # TODO: Need to filter per channel
      record current_users: {
        count: current_users.count,
        users: current_users,
        time: Time.now.utc
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

  end
end