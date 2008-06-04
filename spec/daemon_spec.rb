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

  it "should connect" do
    socket = mock("socket", :null_object => true)
    TCPSocket.should_receive(:new).with('irc.freenode.net', 6667).and_return(socket)

    d = daemon
    d.send(:connect, 'irc.freenode.net', 6667)
    d.instance_variable_get("@socket").should == socket
  end

  it "should authenticate" do
    socket = mock("socket", :null_object => true)
    socket.should_receive(:print).with("NICK nick\r\n").ordered
    socket.should_receive(:print).with("USER spec xxx xxx :Spec User\r\n").ordered

    d = daemon
    d.instance_variable_set("@socket", socket)
    d.send(:authenticate, 'nick', 'spec', 'Spec User')
  end
end
