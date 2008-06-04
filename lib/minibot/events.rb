module MiniBot
  module Events
    def message(channel, user, message)
    end

    def message_to_self(channel, user, message)
    end

    def private_message(user, message)
    end

    def user_joined(channel, user)
    end

    def user_parted(channel, user)
    end

    def invited(channel, user)
    end

    def default(command_str)
    end

    private

    def dispatch(command)
      if match = (/^:(\w+)!.+ INVITE \w+ :(#\w+)/.match command)
        send :invited, match[2], match[1]
      elsif match = (/^:(\w+)!.+ PRIVMSG (#\w+) :(.+)/.match command)
        send :message, match[2], match[1], match[3]
      elsif match = (/^PING/.match command)
        send :pong
      else
        send :default, command
      end
    end

    def pong
      puts "PONGing"
      write "PONG #{@host_name}"
    end
  end
end
