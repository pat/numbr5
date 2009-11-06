require 'spec/spec_helper'

describe Numbr5::Bot do
  before :each do
    @bot = Numbr5::Bot.new(:event_machine_placeholder, 'spec')
    @bot.stub!(:send_data => true)
  end
  
  describe '#receive_line' do
    context 'No Ident response' do
      it "should send the user nickname" do
        @bot.should_receive(:send_data).with("NICK numbr5")
        
        @bot.receive_line '*** No Ident response'
      end
      
      it "should send the user details" do
        @bot.should_receive(:send_data).with("USER numbr5 0 * :Number 5")
        
        @bot.receive_line '*** No Ident response'
      end
      
      it "should join the given channel" do
        @bot.should_receive(:send_data).with("JOIN #spec")
        
        @bot.receive_line '*** No Ident response'
      end
    end
    
    context 'PING' do
      it "should respond with a pong" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/^PONG /)
        end
        
        @bot.receive_line 'PING :default'
      end
      
      it "should direct the pong at a server" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/PONG :default/)
        end
        
        @bot.receive_line 'PING :default'
      end
      
      it "should respect the given server name" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/PONG :spec/)
        end
        
        @bot.receive_line 'PING :spec'
      end
    end
    
    context 'PRIVMSG numbr5' do
      it "should respond with a private message" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/^PRIVMSG/)
        end
        
        @bot.receive_line ':pat!~pat@freelancing-god PRIVMSG numbr5 :hello?'
      end
      
      it "should direct the message to the sender" do
        @bot.should_receive(:send_data) do |data|
          data.should match(/^PRIVMSG pat/)
        end
        
        @bot.receive_line ':pat!~pat@freelancing-god PRIVMSG numbr5 :hello?'
      end
      
      it "should provide beer stats if asked for" do
        RestClient.stub!(
          :get => '{"user":{"name":"pat","beers_owing":2,"beers_owed":0}}'
        )
        @bot.should_receive(:send_data).with('PRIVMSG pat :You owe 2 beers and are owed 0 beers')
        
        @bot.receive_line ':pat!~pat@freelancing-god PRIVMSG numbr5 :stats'
      end
      
      it "should handle 404 errors if the user doesn't have any stats" do
        RestClient.stub(:get).and_raise(RestClient::ResourceNotFound)
        
        @bot.should_receive(:send_data).with('PRIVMSG pat :You owe 0 beers and are owed 0 beers')
        
        @bot.receive_line ':pat!~pat@freelancing-god PRIVMSG numbr5 :stats'
      end
    end
    
    context 'PRIVMSG #channel' do
      before :each do
        RestClient.stub!(:post => true)
      end
      
      it "should not do anything if there was no action" do
        @bot.should_not_receive(:send_data)
        
        @bot.receive_line ':pat!~pat@freelancing-god PRIVMSG #spec :cough'
      end
      
      it "should ignore actions that aren't thanks" do
        @bot.should_not_receive(:send_data)
        
        @bot.receive_line ":pat!~pat@freelancing-god PRIVMSG #spec :\001ACTION wave"
      end
      
      it "should confirm thanks" do
        @bot.should_receive(:send_data).
          with("PRIVMSG #spec :pat: you owe user a beer for action")
        @bot.receive_line ":pat!~pat@freelancing-god PRIVMSG #spec :\001ACTION thanks user for action"
      end
      
      it "should create the beer via the API" do
        RestClient.should_receive(:post) do |url, payload|
          url.should == 'http://localhost:3000/api/beers.json'
          payload.should == {
            :beer => {
              :from   => 'pat',
              :to     => 'user',
              :reason => 'for action'
            }
          }
        end
        
        @bot.receive_line ":pat!~pat@freelancing-god PRIVMSG #spec :\001ACTION thanks user for action"
      end
      
      it "should send a warning if the from and to users are different" do
        @bot.should_receive(:send_data).
          with("PRIVMSG #spec :pat: no masturbation!")
        @bot.receive_line ":pat!~pat@freelancing-god PRIVMSG #spec :\001ACTION thanks pat for action"
      end
    end
  end
end
