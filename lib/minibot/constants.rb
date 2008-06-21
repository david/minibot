module MiniBot
  module Events
    module Constants
      RPL_WELCOME = "001"
      RPL_NOTOPIC = "331"
      RPL_TOPIC = "332"
      RPL_TOPIC_META = "333"
      ERR_NICKNAMEINUSE = "433"

      EXPECTED_REPLIES_TOPIC = [ RPL_NOTOPIC, [ RPL_TOPIC, RPL_TOPIC_META ], RPL_TOPIC ]
    end
  end
end
