module MiniBot
  module Commands
    def join(channel)
      write "JOIN #{channel}"
    end

  end
end
