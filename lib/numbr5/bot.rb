module Numbr5
  class Bot < EventMachine::Connection
    include EventMachine::Protocols::LineText2
    
    attr_reader :channel
    
    def initialize(channel)
      @channel = channel
    end
    
    def receive_line(data)
      case data
      when /no ident/i
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
      case message.strip
      when 'stats'
        stats user
      else
        send_data "PRIVMSG #{user} :hello"
      end
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
      if from == to
        send_data "PRIVMSG ##{channel} :#{from}: no masturbation!"
        return
      end
      
      RestClient.post 'http://localhost:3000/api/beers.json', :beer => {
        :from   => from,
        :to     => to,
        :reason => reason
      }
      send_data "PRIVMSG ##{channel} :#{from}: you owe #{to} a beer #{reason}"
    end
    
    def stats(user)
      json = RestClient.get "http://localhost:3000/api/users/#{user}.json"
      json = JSON.parse json
      
      send_data "PRIVMSG #{user} :You owe #{json['user']['beers_owing']} beers and are owed #{json['user']['beers_owed']} beers"
    rescue RestClient::ResourceNotFound
      send_data "PRIVMSG #{user} :You owe 0 beers and are owed 0 beers"
    end
  end
end
