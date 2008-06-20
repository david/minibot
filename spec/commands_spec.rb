require File.join(File.dirname(__FILE__), 'spec_helper')

describe "MiniBot::Commands" do
  class CommandBot
    include MiniBot::Commands

    def initialize(server = nil)
      @server = server
    end

    attr_reader :server
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
    it "should return the topic data" do
      bot = CommandBot.new(mock "server")
      bot.server.should_receive(:write).
        with("TOPIC #datamapper", *MiniBot::Commands::TOPIC_REPLIES).
        and_yield("332", "Documentation! http://datamapper.rubyforge.org/").
        and_yield("333", "ssmoot 1212697142")
      Time.should_receive(:at).with(1212697142).and_return("whoa")

      topic, author, time = bot.topic "#datamapper" 
      topic.should == "Documentation! http://datamapper.rubyforge.org/"
      author.should == "ssmoot"
      time.should == "whoa"
    end

    it "should return nil for no topic" do
      bot = CommandBot.new(mock "server")
      bot.server.should_receive(:write).
        with("TOPIC #datamapper", *MiniBot::Commands::TOPIC_REPLIES).
        and_yield("331", "There isn't a topic.")

      topic, author, time = bot.topic "#datamapper" 
      topic.should be_nil
      author.should be_nil
      time.should be_nil
    end

    it "should return only the topic for servers that don't send the metadata" do
      bot = CommandBot.new(mock "server")
      bot.server.should_receive(:write).
        with("TOPIC #datamapper", *MiniBot::Commands::TOPIC_REPLIES).
        and_yield("332", "TOPIC!").
        and_yield("400", "Mary had a little lamb")

      topic, author, time = bot.topic "#datamapper" 
      topic.should == "TOPIC!"
      author.should be_nil
      time.should be_nil
    end
  end
end
