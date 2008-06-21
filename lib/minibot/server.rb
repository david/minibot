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
      if @messages.first && message_complete?(@messages.first)
        to_message(@messages.shift)
      else
        read_messages
        read
      end
    end

    def match_code(code, message)
      if (match = reply?(message)) && match[1] == code
        match[1, 2]
      else
        nil
      end
    end

    def write(msg, *replies)
      @socket.print "#{msg}\r\n"

      unless replies.empty?
        index = 0
        matches, messages = catch :halted do
          loop do
            index, message = next_message(index)
            replies.each do |r|
              case r
              when String
                if match = /:\S+ (#{r}) \S+ :?(.+)/.match(message)
                  throw :halted, [[ match ], [ message ]]
                end
              when Array
                matched = []
                messages = []
                r.each do |ri|
                  if match = /:\S+ (#{ri}) \S+ :?(.+)/.match(message)
                    matched << match
                    messages << message
                    index, message = next_message(index)
                  elsif !matched.empty?
                    index -= matched.length
                    message = matched.first
                    break
                  end
                end

                throw :halted, [matched, messages] unless matched.empty?
              else
                raise ArgumentError, "Unknown reply argument type: #{r.inspect}", caller
              end
            end
          end
        end

        messages.each { |m| delete_message(m) }
        matches.each { |m| yield m[1, 2] }
      end
    end

    def extract(regexp)

    end

    def disconnect
      @socket.close if @socket
    end

    private

    def delete_message(m)
      @messages.delete("#{m}\r")
    end

    def message_complete?(message)
      message[-1] == ?\r
    end

    def to_message(raw)
      raw.chomp
    end

    def next_message(index)
      read_messages if !@messages[index] || !message_complete?(@messages[index])

      [index + 1, to_message(@messages[index])]
    end

    def reply?(msg)
      REPLY_RE.match msg
    end

    def initialize(server, port)
      @server = server
      @port = port
      @messages = []
    end

    def read_messages
      buffer = @socket.recvfrom(512).first
      messages = buffer.split /\n/

      @messages.last << messages.shift if @messages.last && @messages.last[-1] != ?\r

      @messages += messages
    end
  end
end
