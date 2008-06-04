require File.join(File.dirname(__FILE__), 'spec_helper')

describe "MiniBot::Events" do
  describe "#dispatch" do
    class EventBot
      include MiniBot::Events
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

    it "should handle pings" do
      d = EventBot.new
      d.should_receive(:pong)
      d.send :dispatch, "PING :a.server.name"
    end

    it "should dispatch to default when it doesn't know how to handle an event" do
      d = EventBot.new
      d.should_receive(:default).with("This isn't actually an IRC command")
      d.send :dispatch, "This isn't actually an IRC command"
    end
  end
end
