require 'spec/spec_helper'

describe Numbr5::Bot do
  before :each do
    @bot = Numbr5::Bot.new(:event_machine_placeholder, 'spec')
    @bot.stub!(:send_data => true)
  end
  
  describe '#receive_data' do
    context 'No Ident response' do
      it "should send the user nickname" do
        @bot.should_receive(:send_data).with("NICK numbr5")
        
        @bot.receive_data '*** No Ident response'
      end
      
      it "should send the user details" do
        @bot.should_receive(:send_data).with("USER numbr5 0 * :Number 5")
        
        @bot.receive_data '*** No Ident response'
      end
      
      it "should join the given channel" do
        @bot.should_receive(:send_data).with("JOIN #spec")
        
        @bot.receive_data '*** No Ident response'
      end
    end
    
    context 'PING' do
      it "should respond with a pong" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/^PONG /)
        end
        
        @bot.receive_data 'PING :default'
      end
      
      it "should direct the pong at a server" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/PONG :default/)
        end
        
        @bot.receive_data 'PING :default'
      end
      
      it "should respect the given server name" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/PONG :spec/)
        end
        
        @bot.receive_data 'PING :spec'
      end
    end
    
    context 'PRIVMSG numbr5' do
      it "should respond with a private message" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/^PRIVMSG/)
        end
        
        @bot.receive_data ':pat!~pat@freelancing-god PRIVMSG numbr5 :hello?'
      end
      
      it "should direct the message to the sender" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/^PRIVMSG pat/)
        end
        
        @bot.receive_data ':pat!~pat@freelancing-god PRIVMSG numbr5 :hello?'
      end
      
      it "should say hello" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/:hello$/)
        end
        
        @bot.receive_data ':pat!~pat@freelancing-god PRIVMSG numbr5 :hello?'
      end
    end
    
    context 'PRIVMSG #channel' do
      it "should not do anything if there was no action" do
        @bot.should_not_receive(:send_data)
        
        @bot.receive_data ':pat!~pat@freelancing-god PRIVMSG #spec :cough'
      end
      
      it "should ignore actions that aren't thanks" do
        @bot.should_not_receive(:send_data)
        
        @bot.receive_data ":pat!~pat@freelancing-god PRIVMSG #spec :\001ACTION wave"
      end
      
      it "should confirm thanks" do
        @bot.should_receive(:send_data).
          with("PRIVMSG #spec :pat: you owe user a beer for action")
        @bot.receive_data ":pat!~pat@freelancing-god PRIVMSG #spec :\001ACTION thanks user for action"
      end
    end
  end
end
