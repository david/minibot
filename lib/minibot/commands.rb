require 'ostruct'

module MiniBot
  module Commands
    include Events::Constants

    def join(*channels)
      channels.each { |channel| write "JOIN #{channel}" }
    end

    TOPIC_REPLIES = [ RPL_NOTOPIC, [ RPL_TOPIC, RPL_TOPIC_META ], RPL_TOPIC ]

    def topic(channel)
      topic = author = timestamp = nil
      server.write "TOPIC #{channel}", *TOPIC_REPLIES do |code, reply|
        if code == RPL_TOPIC
          topic = reply
        elsif code == RPL_TOPIC_META
          author, timestamp = *reply.split
        end
      end

      [ topic, author, timestamp && Time.at(timestamp.to_i) ] 
    end

    private

    def pong
      write "PONG #{@host_name}"
    end
  end
end
