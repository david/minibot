module MiniBot
  module Events
    include Constants

    def message(channel, sender, message)
    end

    def private_message(sender, message)
    end

    def user_joined(channel, nick)
    end

    def user_parted(channel, nick)
    end

    def user_action(channel, nick, message)
    end

    def invited(channel, nick)
    end

    def default(message_str)
    end

    def pinged
    end

    def topic_changed(channel, nick, topic)
    end

    def kicked(channel, nick, message)
    end

    def user_kicked(channel, kicker, kicked, message)
    end

    def ready
    end

    def error(num, message)
    end

    private

    def dispatch(srv_msg)
      if match = /^:(\w+)!.+ PRIVMSG (\S+) :([^\001].+)/.match(srv_msg)
        target, origin, message = *match.values_at(2, 1, 3)
        unless target == @nick
          message target, origin, message
        else
          private_message origin, message
        end
      elsif match = /^:(\w+)!.+ JOIN :(\S+)/.match(srv_msg)
        user_joined *match.values_at(2, 1)
      elsif match = /^:(\w+)!.+ PART (\S+)/.match(srv_msg)
        user_parted *match.values_at(2, 1)
      elsif match = /^:(\w+)!.+ PRIVMSG (\S+) :\001ACTION (.+)\001/.match(srv_msg)
        user_action *match.values_at(2, 1, 3)
      elsif match = /^:(\w+)!.+ PRIVMSG #{@nick} :(.+)/.match(srv_msg)
        private_message *match.values_at(1, 2)
      elsif match = /^:(\w+)!.+ INVITE \w+ :(\S+)/.match(srv_msg)
        invited *match.values_at(2, 1)
      elsif match = /^PING/.match(srv_msg)
        pinged
      elsif match = /^:(\w+)!.+ TOPIC (\S+) :(.+)/.match(srv_msg)
        topic_changed *match.values_at(2, 1, 3)
      elsif match = /^:(\w+)!.+ KICK (\S+) #{@nick} :(.+)/.match(srv_msg)
        kicked *match.values_at(2, 1, 3)
      elsif match = /^:(\w+)!.+ KICK (\S+) (\w+) :(.+)/.match(srv_msg)
        user_kicked *match.values_at(2, 1, 3, 4)
      elsif match = /^:\S+ #{RPL_WELCOME} .*?(:.*)?$/.match(srv_msg)
        ready
      elsif match = /^:\S+ (\d{3}) \S+ (:.*)?$/.match(srv_msg)
        code, msg = *match.values_at(1, 2)

        if error?(code)
          error code, msg.sub(/:/, '')
        else
          default(srv_msg)
        end
      else
        default(srv_msg)
      end
    end

    def error?(num)
      return ("400" .. "599").include? num
    end
  end
end
