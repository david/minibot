module MiniBot
  class Server
    REPLY_RE = /:\S+ (\d{3}) \S+ :?(.+)/

    def self.connect(server, port)
      s = new(server, port)
      s.connect
      s
    end

    def connect
      @socket = TCPSocket.new(@server, @port)
    end

    def read
      if @buffer.empty?
        @buffer << @socket.recvfrom(512).first
        read
      elsif @buffer.start_with? "\r\n"
        @buffer = @buffer[2 .. -1]
        read
      else
        message, buffer = *@buffer.split(/\r\n/, 2)

        if !message.empty? && buffer
          @buffer = buffer
          message
        else
          @buffer << @socket.recvfrom(512).first
          read
        end
      end
    end

    def write(msg, *replies)
      print_to_socket msg

      unless replies.empty?
        buffer = []
        matches = nil
        until matches
          replies.map { |r| Array === r ? r : [ r ] }.each do |r|
            break if (matches = match(r))
          end

          buffer << read unless matches
        end

        unread *buffer

        if block_given?
          matches.each { |m| yield *m }
        else
          matches
        end
      end
    end

    def disconnect
      @socket.close if @socket
    end

    private

    def match_code(code, message)
      if (match = reply?(message)) && match[1] == code
        match[1, 2]
      else
        nil
      end
    end

    def match(codes)
      catch :halt do 
        matches = []

        codes.each do |code|
          msg = read

          if match = match_code(code, msg)
            matches << match
          else
            unread *matches
            throw :halt, nil
          end
        end

        matches
      end
    end

    def reply?(msg)
      REPLY_RE.match msg
    end

    def initialize(server, port)
      @server = server
      @port = port
      @buffer = ""
    end

    def print_to_socket(msg)
      @socket.print "#{msg}\r\n"
    end

    def unread(*messages)
      @buffer = messages.join("\r\n") << @buffer
    end
  end
end
