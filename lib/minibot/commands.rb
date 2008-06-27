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
          channel, topic = reply.split /\s+/, 2
        elsif code == RPL_TOPIC_META
          channel, author, timestamp = *reply.split
        end
      end

      [ topic && topic[1 .. -1], author, timestamp && Time.at(timestamp.to_i) ] 
    end

    def say(target, message)
    end

    def set_user(username, realname)
      @server.write "USER #{username} 0 xxx :#{realname}"
    end

    def set_nick(nick)
      @server.write "NICK #{nick}"
    end

    def nickserv(command)
      @server.write "NICKSERV #{command}"
    end

    private

    def pong
      @server.write "PONG #{@host_name}"
    end
  end
end
