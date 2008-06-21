require 'ostruct'

module MiniBot
  module Commands
    include Events::Constants

    def join(*channels)
      channels.each { |channel| server.write "JOIN #{channel}" }
    end

    def topic(channel)
      topic = author = timestamp = nil
      server.write "TOPIC #{channel}", *EXPECTED_REPLIES_TOPIC do |code, reply|
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
