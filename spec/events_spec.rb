require File.join(File.dirname(__FILE__), 'spec_helper')

describe "MiniBot::Events" do
  describe "#dispatch" do
    class EventBot
      include MiniBot::Events

      def initialize
        @nick = "enick"
      end
    end

    it "should dispatch invites" do
      d = EventBot.new
      d.should_receive(:invited).with('#ior3k', 'ior3k')
      d.send :dispatch, ":ior3k!n=david@89.152.220.123 INVITE nnn :#ior3k"
    end

    it "should dispatch messages" do
      d = EventBot.new
      d.should_receive(:message).with('#ior3k', 'ior3k', 'This is a test message!')
      d.send :dispatch, ":ior3k!n=david@89.152.220.123 PRIVMSG #ior3k :This is a test message!"
    end

    it "should dispatch user actions" do
      d = EventBot.new
      d.should_receive(:user_action).with('#ior3k', 'ior3k', 'is testing this')
      d.send :dispatch, ":ior3k!n=david@89.152.220.123 PRIVMSG #ior3k :\001ACTION is testing this\001"
    end

    it "should dispatch private messages" do
      d = EventBot.new
      d.should_receive(:private_message).with('ior3k', 'This is a test message!')
      d.send :dispatch, ":ior3k!n=david@89.152.220.123 PRIVMSG enick :This is a test message!"
    end
    
    it "should handle pings" do
      d = EventBot.new
      d.should_receive(:pinged)
      d.send :dispatch, "PING :a.server.name"
    end

    it "should dispatch to default when it doesn't know how to handle an event" do
      d = EventBot.new
      d.should_receive(:default).with("This isn't actually an IRC command")
      d.send :dispatch, "This isn't actually an IRC command"
    end

    it "should dispatch joins" do
      d = EventBot.new
      d.should_receive(:user_joined).with('#ior3k', 'ior3k')
      d.send :dispatch, ":ior3k!n=ior3k@213.63.55.41 JOIN :#ior3k"
    end

    it "should dispatch parts" do
      d = EventBot.new
      d.should_receive(:user_parted).with('#ior3k', 'ior3k')
      d.send :dispatch, ":ior3k!n=ior3k@213.63.55.41 PART :#ior3k"
    end

    it "should dispatch ready" do
      d = EventBot.new
      d.should_receive(:ready)
      d.send :dispatch, ":calvino.freenode.net 001 ior3k :Welcome to the freenode IRC Network ior3k"
    end

    it "should dispatch errors" do
      d = EventBot.new
      d.should_receive(:error).with(433, "Nickname is already in use.")
      d.send :dispatch, ":card.freenode.net 433 * logbot :Nickname is already in use."
    end

    it "should dispatch topic changes" do
      d = EventBot.new
      d.should_receive(:topic_changed).with('#ior3k', 'ior3k', 'd00dz!')
      d.send :dispatch, ":ior3k!n=david@89.152.220.123 TOPIC #ior3k :d00dz!"
    end

    it "should dispatch when bot is kicked" do
      d = EventBot.new
      d.should_receive(:kicked).with('#ior3k', 'ior3k', 'd00dz!')
      d.send :dispatch, ":ior3k!n=david@89.152.220.123 KICK #ior3k enick :d00dz!"
    end

    it "should dispatch when user is kicked" do
      d = EventBot.new
      d.should_receive(:user_kicked).with('#ior3k', 'ior3k', 'victim', 'd00dz!')
      d.send :dispatch, ":ior3k!n=david@89.152.220.123 KICK #ior3k victim :d00dz!"
    end
  end
end
