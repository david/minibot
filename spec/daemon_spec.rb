require File.join(File.dirname(__FILE__), 'spec_helper')

describe MiniBot::Daemon do
  def config
      { :server => 'irc.freenode.net',
        :username => 'spec',
        :nick => 'nick',
        :realname => 'Spec User' }
  end

  def daemon(opts = {})
    MiniBot::Daemon.new(config.merge(opts))
  end

  describe "defaults" do
    it "should use the default port when no port is specified" do
      socket = mock("socket", :null_object => true)

      d = daemon
      d.instance_variable_get("@config")[:port].should == 6667
    end

    it "should use the nick when the username is not specified" do
      socket = mock("socket", :null_object => true)

      d = daemon(:username => nil)
      d.instance_variable_get("@config")[:username].should == 'nick'
    end

    it "should return an empty array when no channels are specified" do
      socket = mock("socket", :null_object => true)

      d = daemon
      d.instance_variable_get("@config")[:channels].should == []
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

  describe "running" do
    it "should auto join channels" do
      channels = %w{#one #two}
      d = daemon({ :channels => channels })
      d.stub!(:connect)
      d.stub!(:authenticate)
      d.stub!(:main_loop)

      d.should_receive(:join).with("#one", "#two")
      d.run
    end
  end

  describe "reading" do
    it "should fetch commands" do
      socket = mock("socket", :null_object => true)
      buffer = ("a" * 254) + "\r\n" + ("b" * 254) + "\r\n"
      socket.stub!(:recvfrom).and_return([buffer, nil])

      d = daemon

      d.instance_variable_set("@socket", socket)
      d.send :read_commands
    end

    it "should return complete commands only" do
      socket = mock("socket", :null_object => true)
      buffer = ("a" * 254) + "\r\n" + ("b" * 256)
      socket.stub!(:recvfrom).and_return([buffer, nil])

      d = daemon

      d.instance_variable_set("@socket", socket)
      d.send :read_commands
      d.send(:next_command).should == "a" * 254
      d.send(:next_command).should be_nil
      d.instance_variable_get("@commands").first.should == ("b" * 256)
    end

    it "should join incomplete commands" do
      socket = mock("socket", :null_object => true)
      buffer = ("a" * 254) + "\r\n" + ("b" * 256)
      socket.stub!(:recvfrom).and_return([buffer, nil])

      d = daemon

      d.instance_variable_set("@socket", socket)
      d.send :read_commands
      d.send :next_command

      socket.stub!(:recvfrom).and_return(["bbbb\r\n", nil])
      d.send :read_commands
      d.send(:next_command).should == "b" * 260
    end
  end
end
