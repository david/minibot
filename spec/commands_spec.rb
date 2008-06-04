require File.join(File.dirname(__FILE__), 'spec_helper')

describe "MiniBot::Commands" do
  class CommandBot
    include MiniBot::Commands
  end

  it "should join a channel" do
    bot = CommandBot.new
    bot.should_receive(:write).with("JOIN #testchannel")
    bot.join "#testchannel"
  end
end
