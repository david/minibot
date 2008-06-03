require File.join(File.dirname(__FILE__), 'spec_helper')

describe MiniBot::Daemon do
  def daemon(options = {})
    MiniBot::Daemon.new(
      { :server => 'irc.freenode.net',
        :username => 'spec',
        :nick => 'nick',
        :realname => 'Spec User' }.merge(options)
    )
  end

  it "should connect to a server" do
    socket = mock("socket")
    socket.should_receive(:print).with("NICK nick\r\n").ordered
    socket.should_receive(:print).with("USER spec xxx xxx :Spec User\r\n").ordered

    TCPSocket.should_receive(:new).with('irc.freenode.net', 6667).and_return(socket)

    d = daemon
    d.should_receive(:main_loop)
    d.should_receive(:close)

    d.run
  end

  describe "#dispatch" do
    before do
      @socket = mock("socket", :null_object => true)

      TCPSocket.stub!(:new).and_return(@socket)
    end

    it "should dispatch invites" do
      d = daemon

      tester = mock("tester")
      tester.should_receive(:call).with("#ior3k", "ior3k")
      d.event :invite do |channel, user|
        tester.call channel, user
      end

      d.send :dispatch, ":ior3k!n=david@89.152.220.123 INVITE nnn :#ior3k"
    end

    it "should dispatch messages, unconditionally" do
      d = daemon

      tester = mock("tester")
      tester.should_receive(:call).with("#ior3k", "ior3k", "This is a test message!")
      d.event :message do |channel, user, message|
        tester.call channel, user, message
      end

      d.send :dispatch, ":ior3k!n=david@89.152.220.123 PRIVMSG #ior3k :This is a test message!"
    end
  end
end
