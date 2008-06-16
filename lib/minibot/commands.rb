module MiniBot
  module Commands
    def join(*channels)
      channels.each { |channel| write "JOIN #{channel}" }
    end

    private

    def write(str)
      socket.print "#{str}\r\n"
    end

    def pong
      write "PONG #{@host_name}"
    end
  end
end
