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
      d.should_receive(:user_joined)
      d.send :dispatch, ":ior3k!n=ior3k@213.63.55.41 JOIN :#ior3k"
    end

    it "should dispatch parts" do
      d = EventBot.new
      d.should_receive(:user_parted)
      d.send :dispatch, ":ior3k!n=ior3k@213.63.55.41 PART :#ior3k"
    end
  end
end
