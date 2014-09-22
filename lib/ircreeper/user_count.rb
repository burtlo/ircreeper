
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
      record users: {
        user: m.user.nick,
        time: Time.now.utc,
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
      record users: {
        user: m.user.nick,
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

  end
end