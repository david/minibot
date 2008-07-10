require File.join(File.dirname(__FILE__), 'spec_helper')

describe MiniBot::Server do
  def server
    MiniBot::Server.new "x", "x"
  end

  it "should connect" do
    socket = mock "socket" 
    TCPSocket.should_receive(:new).with('irc.freenode.net', 6667).and_return(socket)

    s = MiniBot::Server.connect('irc.freenode.net', 6667)
    s.instance_variable_get("@socket").should == socket
  end

  it "should fetch messages" do
    socket = mock "socket", :null_object => true
    buffer1 = ("a" * 154) + "\r\n" + ("b" * 354) + "\r\n"
    socket.stub!(:recvfrom).and_return([buffer1, nil])

    s = server

    s.instance_variable_set "@socket", socket
    s.send(:read).should == ('a' * 154)
    s.send(:read).should == ('b' * 354)
  end

  it "should write messages" do
    s = server
    s.should_receive(:print_to_socket).with("how now brown cow")
    s.write "how now brown cow"
  end

  # TODO: go back to mocking the socket. Tests are hard to understand this way.
  describe "writing with replies" do
    it "should return the right reply" do
      s = server
      s.stub!(:print_to_socket)
      s.should_receive(:read).and_return("aaa", "aaa", ":my.server.com 432 whatever :A message")

      tester = mock "tester"
      tester.should_receive(:call).with("432", "A message")
      s.write("duh", "432") { |code, reply| tester.call code, reply }
    end

    it "should return all replies when it's passed an array" do
      s = server
      s.stub!(:print_to_socket)
      s.should_receive(:read).and_return(
        "aaa", 
        "aaa", 
        ":my.server.com 433 whatever :A message2", 
        ":my.server.com 432 whatever :A message"
      )

      tester = mock "tester"
      tester.should_receive(:call).with("433", "A message2")
      tester.should_receive(:call).with("432", "A message")
      s.write("duh", ["433", "432"]) { |code, reply| tester.call code, reply }
    end

    it "should return the second choice when one of the array's codes doesn't match" do
      socket = mock "socket"
      socket.stub! :print

      s = server
      s.instance_variable_set "@socket", socket
      s.instance_variable_set "@buffer", 
        "aaa\r\n" << 
        ":my.server.com 433 whatever :A message2\r\n" << 
        "bbb\r\n" <<
        ":my.server.com 432 whatever :A message\r\n"

      tester = mock "tester"
      tester.should_receive(:call).with("433", "A message2")
      s.write("duh", ["433", "432"], "433") { |code, reply| tester.call code, reply }
    end

    it "should put back unused messages" do
      s = server
      s.stub!(:print_to_socket)
      s.should_receive(:read).and_return(
        "aaa",
        "aaa", 
        ":my.server.com 433 whatever :A message2", 
        ":my.server.com 432 whatever :A message"
      )
      s.should_receive(:unread).with(no_args)
      s.should_receive(:unread).with("aaa")

      s.write("duh", ["433", "432"])
    end
  end

  describe "returning the next message" do
    it "should return a complete message" do
      socket = mock "socket", :null_object => true
      buffer = ("a" * 254) + "\r\n" + ("b" * 256)
      socket.should_receive(:recvfrom).and_return([buffer, nil])

      s = server
      s.instance_variable_set "@socket", socket

      s.read.should == "a" * 254
      s.instance_variable_get("@buffer").should == ("b" * 256)
    end

    it "should skip over empty messages" do
      socket = mock "socket", :null_object => true
      buffer = "\r\n" << ("a" * 254) << "\r\n" << ("b" * 256) << "\r\n"
      socket.should_receive(:recvfrom).and_return([buffer, nil])

      s = server
      s.instance_variable_set "@socket", socket

      s.read.should == "a" * 254
      s.instance_variable_get("@buffer").should == ("b" * 256) << "\r\n"
    end

    it "should join incomplete messages" do
      socket = mock "socket", :null_object => true
      buffer = "b" * 256
      socket.should_receive(:recvfrom).and_return(["bbbb\r\n", nil])

      s = server
      s.instance_variable_set "@socket", socket
      s.instance_variable_set "@buffer", buffer

      s.read.should == "b" * 260
    end

    it "should return a single complete message" do
      s = server
      s.instance_variable_set "@buffer", ("b" * 256) + "\r\n"

      s.read.should == "b" * 256
      s.instance_variable_get("@buffer").should == ""
    end
  end

  it "should disconnect" do
    socket = mock "socket"
    socket.should_receive(:close)

    s = server
    s.instance_variable_set "@socket", socket

    s.disconnect
  end
end
