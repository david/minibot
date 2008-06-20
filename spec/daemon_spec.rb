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

  it "should connect" do
    d = daemon
    MiniBot::Server.should_receive(:connect).with('server', 'port')
    d.send :connect, 'server', 'port'
  end

  it "should authenticate" do
    server = mock("server", :null_object => true)
    server.should_receive(:write).with("USER spec 0 xxx :Spec User").ordered
    server.should_receive(:write).with("NICK nick").ordered

    d = daemon
    d.instance_variable_set("@server", server)
    d.should_receive(:server).any_number_of_times.and_return(server)
    d.send(:authenticate, 'nick', 'spec', 'Spec User')
  end

  describe "running" do
    it "should auto join channels" do
      channels = %w{#one #two}
      d = daemon({ :channels => channels })
      d.stub!(:connect)
      d.stub!(:authenticate)
      d.stub!(:main_loop)
      d.stub!(:disconnect)

      d.should_receive(:join).with("#one", "#two")
      d.run
    end
  end
end
