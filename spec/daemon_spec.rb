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
      d.instance_variable_get("@port").should == 6667
    end

    it "should use the nick when the username is not specified" do
      socket = mock("socket", :null_object => true)

      d = daemon(:username => nil)
      d.instance_variable_get("@username").should == 'nick'
    end
  end

  it "should connect" do
    d = daemon
    MiniBot::Server.should_receive(:connect).with('server', 'port')
    d.send :connect, 'server', 'port'
  end

  it "should login" do
    d = daemon
    d.should_receive(:set_user).with('user', 'real name')
    d.send :login, 'user', 'real name'
  end

  describe "should identify" do
    it "with a password" do
      d = daemon
      d.should_receive(:set_nick).with('nick')
      d.should_receive(:nickserv).with('identify hello')
      d.send :identify, 'nick', 'hello'
    end

    it "without a password" do
      d = daemon
      d.should_receive(:set_nick).with('nick')
      d.should_not_receive(:nickserv)
      d.send :identify, 'nick'
    end
  end
end
