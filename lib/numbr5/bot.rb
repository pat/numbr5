module Numbr5
  class Bot < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    
    attr_reader :channel
    
    def initialize(channel)
      @channel = channel
    end
    
    def receive_data(data)
      case data
      when /No Ident response/
        identify_and_join
      when /^PING /
        pong data.gsub(/^PING /i, '')
      when / PRIVMSG numbr5 /
        match = data.match(/:([^!]+).+ PRIVMSG numbr5 :(.+)/)
        private_message match[1], match[2]
      when / PRIVMSG ##{channel}/
        match = data.match(/:([^!]+).+ PRIVMSG ##{channel} :(.+)$/)
        public_message match[1], match[2]
      end
    end
    
    private
    
    def send_data(data)
      puts "SENDING #{data}"
      super(data + "\r\n")
    end
    
    def identify_and_join
      send_data "NICK numbr5"
      send_data "USER numbr5 0 * :Number 5"
      send_data "JOIN ##{channel}"
    end
    
    def pong(data = 'irc')
      send_data "PONG #{data}"
    end
    
    def private_message(user, message)
      send_data "PRIVMSG #{user} :hello"
    end
    
    def public_message(user, message)
      if message[/^.ACTION/]
        match = message.match(/^.ACTION (\w+)($| .+$)/)
        action user, match[1], match[2].strip
      end
    end
    
    def action(user, action, message)
      case action
      when 'thanks'
        match = message.match(/^(\w+) (.+)$/)
        thank user, match[1], match[2]
      end
    end
    
    def thank(from, to, reason)
      send_data "PRIVMSG ##{channel} :#{from}: you owe #{to} a beer #{reason}"
    end
  end
end
