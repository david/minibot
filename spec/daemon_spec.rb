require File.join(File.dirname(__FILE__), 'spec_helper')

describe MiniBot::Daemon do
  def options
      { :server => 'irc.freenode.net',
        :username => 'spec',
        :nick => 'nick',
        :realname => 'Spec User' }
  end

  def daemon(opts = {})
    MiniBot::Daemon.new(options.merge(opts))
  end

  describe "defaults" do
    it "should use the default port when no port is specified" do
      socket = mock("socket", :null_object => true)

      d = daemon
      d.instance_variable_get("@options")[:port].should == 6667
    end

    it "should use the nick when the username is not specified" do
      socket = mock("socket", :null_object => true)

      d = daemon(:username => nil)
      d.instance_variable_get("@options")[:username].should == 'nick'
    end
  end

  it "should authenticate" do
    socket = mock("socket", :null_object => true)
    socket.should_receive(:print).with("USER spec 0 xxx :Spec User\r\n").ordered
    socket.should_receive(:print).with("NICK nick\r\n").ordered

    d = daemon
    d.should_receive(:socket).any_number_of_times.and_return(socket)
    d.send(:authenticate, 'nick', 'spec', 'Spec User')
  end

  it "should connect" do
    socket = mock("socket", :null_object => true)
    TCPSocket.should_receive(:new).with('irc.freenode.net', 6667).and_return(socket)

    d = daemon
    d.send(:connect, 'irc.freenode.net', 6667)
    d.instance_variable_get("@socket").should == socket
  end

  describe "error handling" do
    it "should raise on unknow errors" do
      d = daemon
      lambda { d.error 433, "This is a message!" }.should raise_error(RuntimeError)
    end
  end
end
