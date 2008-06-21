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
    buffer = ("a" * 254) + "\r\n" + ("b" * 254) + "\r\n"
    socket.stub!(:recvfrom).and_return([buffer, nil])

    s = server

    s.instance_variable_set "@socket", socket
    s.send :read_messages
    s.instance_variable_get("@messages").should == buffer.split(/\n/)
  end

  it "should write messages" do
    socket = mock "socket"
    socket.should_receive(:print).with("how now brown cow\r\n")

    s = server
    s.instance_variable_set "@socket", socket
    s.write "how now brown cow"
  end

  describe "writing with replies" do
    describe "advancing messages" do
      it "should not destroy them" do
        s = server
        s.instance_variable_set "@messages", ["aaa\r", "bbb\r"]

        cursor, msg = s.send :next_message, 0
        cursor.should == 1
        msg.should == "aaa"

        cursor, msg = s.send :next_message, cursor
        cursor.should == 2
        msg.should == "bbb"

        s.instance_variable_get("@messages").should == ["aaa\r", "bbb\r"]
      end

      it "should fetch new ones when no more are left" do
        socket = mock "socket", :null_object => true
        socket.stub!(:recvfrom).and_return(["aaa\r\nbbb\r\n", nil])

        s = server
        s.instance_variable_set "@socket", socket
        s.instance_variable_set "@messages", []

        cursor, msg = s.send :next_message, 0
        msg.should == "aaa"
      end

      it "should detect incomplete ones and fetch more before returning" do
        socket = mock "socket", :null_object => true
        socket.stub!(:recvfrom).and_return(["aaa\r\nbbb\r\n", nil])

        s = server
        s.instance_variable_set "@socket", socket
        s.instance_variable_set "@messages", ["aa"]

        cursor, msg = s.send :next_message, 0
        msg.should == "aaaaa"
      end
    end

    it "should return the right reply" do
      socket = mock "socket"
      socket.stub! :print

      s = server
      s.instance_variable_set "@socket", socket
      s.instance_variable_set "@messages", ["aaa\r", ":my.server.com 432 whatever :A message\r"]

      tester = mock "tester"
      tester.should_receive(:call).with("432", "A message")
      s.write("duh", "432") { |code, reply| tester.call code, reply }
    end

    it "should return the second wanted reply when it's found first" do
      socket = mock "socket"
      socket.stub! :print

      s = server
      s.instance_variable_set "@socket", socket
      s.instance_variable_set "@messages", [
        "aaa\r", 
        ":my.server.com 433 whatever :A message2\r", 
        ":my.server.com 432 whatever :A message\r"
      ]

      tester = mock "tester"
      tester.should_receive(:call).with("433", "A message2")
      s.write("duh", "433") { |code, reply| tester.call code, reply }
    end

    it "should return all replies when it's passed an array" do
      socket = mock "socket", :null_object => true
      socket.stub! :print
      socket.stub!(:recvfrom).and_return("1\r\n")

      s = server
      s.instance_variable_set "@socket", socket
      s.instance_variable_set "@messages", [
        "aaa\r", 
        ":my.server.com 433 whatever :A message2\r", 
        ":my.server.com 432 whatever :A message\r"
      ]

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
      s.instance_variable_set "@messages", [
        "aaa\r", 
        ":my.server.com 433 whatever :A message2\r", 
        "bbb\r",
        ":my.server.com 432 whatever :A message\r"
      ]

      tester = mock "tester"
      tester.should_receive(:call).with("433", "A message2")
      s.write("duh", ["433", "432"], "433") { |code, reply| tester.call code, reply }
    end

    it "should delete replies from message buffer" do
      socket = mock "socket", :null_object => true
      socket.stub! :print
      socket.stub!(:recvfrom).and_return("1\r\n")

      s = server
      s.instance_variable_set "@socket", socket
      s.instance_variable_set "@messages", [
        "aaa\r", 
        ":my.server.com 433 whatever :A message2\r", 
        ":my.server.com 432 whatever :A message\r"
      ]

      s.write("duh", ["433", "432"]) { |code, reply| nil }
      s.instance_variable_get("@messages").should == ["aaa\r", "1\r"]
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
      s.instance_variable_get("@messages").should == ["b" * 256]
    end

    it "should join incomplete messages" do
      socket = mock "socket", :null_object => true
      buffer = "b" * 256
      socket.should_receive(:recvfrom).and_return(["bbbb\r\n", nil])

      s = server
      s.instance_variable_set "@socket", socket
      s.instance_variable_set "@messages", [buffer]

      s.read.should == "b" * 260
    end

    it "should return a single complete messages" do
      s = server
      s.instance_variable_set "@messages", [("b" * 256) + "\r"]

      s.read.should == "b" * 256
      s.instance_variable_get("@messages").should == []
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
