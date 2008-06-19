require 'ostruct'

module MiniBot
  module Commands
    def join(*channels)
      channels.each { |channel| write "JOIN #{channel}" }
    end

    def topic(channel)
      write "TOPIC #{channel}"

      # TODO: This is ugly.
      topic = meta = nil
      until topic && meta
        read_commands
        commands.each do |c|
          if (match = /:\S+ 332 \S+ #{channel} :(.+)/.match c)
            topic = match
          elsif (match = /:\S+ 333 \S+ #{channel} (.+) (\d+)/.match c)
            meta = match
          end
        end
      end

      [ topic[1].chomp, meta[1].chomp, Time.at(meta[1].chomp.to_i) ] 
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
