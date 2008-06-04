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
  end
end
