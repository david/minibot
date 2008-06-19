require File.join(File.dirname(__FILE__), 'spec_helper')

describe "MiniBot::Commands" do
  class CommandBot
    include MiniBot::Commands
  end

  describe "#join" do
    it "should join a channel" do
      bot = CommandBot.new
      bot.should_receive(:write).with("JOIN #testchannel")
      bot.join "#testchannel"
    end

    it "should join multiple channels" do
      bot = CommandBot.new
      bot.should_receive(:write).with("JOIN #testchannel")
      bot.should_receive(:write).with("JOIN #anotherchannel")
      bot.join "#testchannel", "#anotherchannel"
    end
  end

  describe "#topic" do
    it "should return the right data" do
      commands = [ 
        ":zelazny.freenode.net 332 ee123 #datamapper :Documentation! http://datamapper.rubyforge.org/",
        ":zelazny.freenode.net 333 ee123 #datamapper ssmoot 1212697142" ]
      bot = CommandBot.new
      bot.should_receive(:write).with("TOPIC #datamapper")
      bot.stub!(:read_commands)
      bot.stub!(:commands).and_return(commands)
      Time.should_receive(:at).with(1212697142).and_return("whoa")

      topic, author, time = bot.topic "#datamapper" 
      topic.should == "Documentation! http://datamapper.rubyforge.org/"
      author.should == "ssmoot"
      time.should == "whoa"
    end
  end
end
