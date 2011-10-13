require "eventmachine"

class SharedInfo
  class << self
    attr_accessor :text
  end
end

module Server1
  def initialize
    SharedInfo.text = "default value"
    send_data "Type to set a message to SharedInfo.text."
  end
  
  def receive_data(data)
    SharedInfo.text = data
    puts "=> SharedInfo.text: #{data}"
  end
end

module Server2
  def initialize
    send_data "You can get a message from SharedInfo.text."
  end
  
  def receive_data(data)
    puts "<= SharedInfo.text: #{SharedInfo.text}"
    send_data "SharedInfo.text: #{SharedInfo.text}"
  end
end

module Runner
  def self.run(host="0.0.0.0", port1=5000, port2=6000)
    Signal.trap("INT")  { EventMachine.stop }
    Signal.trap("TERM") { EventMachine.stop }
    
    EM.run {
      start_server(host, port1, Server1)
      start_server(host, port2, Server2)
    }
  end
  
  private
  
  def self.start_server(host, port, handler)
    EM.start_server(host, port, handler)
    puts "Now accepting connections on address #{host}, port #{port}"
  end
end

Runner.run

# telnet 0.0.0.0 5000
# telnet 0.0.0.0 6000
