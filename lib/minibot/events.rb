module MiniBot
  module Events
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

    private

    def dispatch(command)
      if match = (/^:(\w+)!.+ PRIVMSG (#\w+) :([^\001].+)/.match command)
        send :message, match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ JOIN :(#\w+)/.match command)
        send :user_joined, match[2], match[1]
      elsif match = (/^:(\w+)!.+ PART :(#\w+)/.match command)
        send :user_parted, match[2], match[1]
      elsif match = (/^:(\w+)!.+ PRIVMSG (#\w+) :\001ACTION (.+)\001/.match command)
        send :user_action, match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ PRIVMSG #{@nick} :(.+)/.match command)
        send :private_message, match[1], match[2]
      elsif match = (/^:(\w+)!.+ INVITE \w+ :(#\w+)/.match command)
        send :invited, match[2], match[1]
      elsif match = (/^PING/.match command)
        send :pinged
      elsif match = (/^:(\w+)!.+ TOPIC (#\w+) :(.+)/.match command)
        send :topic_changed, match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ KICK (#\w+) #{@nick} :(.+)/.match command)
        send :kicked, match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ KICK (#\w+) (\w+) :(.+)/.match command)
        send :user_kicked, match[2], match[1], match[3], match[4]
      else
        send :default, command
      end
    end
  end
end
