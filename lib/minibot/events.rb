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

    def default(command_str)
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

    def dispatch(command)
      if match = (/^:(\w+)!.+ PRIVMSG (#\w+) :([^\001].+)/.match command)
        message match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ JOIN :(#\w+)/.match command)
        user_joined match[2], match[1]
      elsif match = (/^:(\w+)!.+ PART (#\w+)/.match command)
        user_parted match[2], match[1]
      elsif match = (/^:(\w+)!.+ PRIVMSG (#\w+) :\001ACTION (.+)\001/.match command)
        user_action match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ PRIVMSG #{@nick} :(.+)/.match command)
        private_message match[1], match[2]
      elsif match = (/^:(\w+)!.+ INVITE \w+ :(#\w+)/.match command)
        invited match[2], match[1]
      elsif match = (/^PING/.match command)
        send :pinged
      elsif match = (/^:(\w+)!.+ TOPIC (#\w+) :(.+)/.match command)
        topic_changed match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ KICK (#\w+) #{@nick} :(.+)/.match command)
        kicked match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ KICK (#\w+) (\w+) :(.+)/.match command)
        user_kicked match[2], match[1], match[3], match[4]
      elsif match = (/^:\S+ (\d{3}).*?(:.*)?$/.match command)
        code = match[1].to_i

        if code == RPL_WELCOME
          ready
        elsif error?(code)
          error code, match[2].sub(/:/, '')
        end
      else
        default command
      end
    end

    def error?(num)
      return (400 .. 599).include? num
    end
  end
end
