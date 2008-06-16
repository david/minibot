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
end
