module MiniBot
  module Events
    def message(channel, sender, message)
    end

    def private_message(sender, message)
    end

    def user_joined(channel, user)
    end

    def user_parted(channel, user)
    end

    def user_action(channel, user, message)
    end

    def invited(channel, user)
    end

    def default(command_str)
    end

    def pinged
    end

    private

    def dispatch(command)
      if match = (/^:(\w+)!.+ PRIVMSG (#\w+) :\001ACTION (.+)\001/.match command)
        send :user_action, match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ PRIVMSG (#\w+) :(.+)/.match command)
        send :message, match[2], match[1], match[3]
      elsif match = (/^:(\w+)!.+ JOIN :(#\w+)/.match command)
        send :user_joined, match[3], match[1]
      elsif match = (/^:(\w+)!.+ PART :(#\w+)/.match command)
        send :user_parted, match[3], match[1]
      elsif match = (/^:(\w+)!.+ PRIVMSG #{@nick} :(.+)/.match command)
        send :private_message, match[1], match[2]
      elsif match = (/^:(\w+)!.+ INVITE \w+ :(#\w+)/.match command)
        send :invited, match[2], match[1]
      elsif match = (/^PING/.match command)
        send :pinged
      else
        send :default, command
      end
    end
  end
end
