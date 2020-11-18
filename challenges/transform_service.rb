require 'socket'

class TransformService
  def initialize(port)
    server = TCPServer.new(port)

    loop do
      client = server.accept

      while input = client.gets
        puts "Received #{input.chomp} from a client socket on #{port}"
        client.puts capitalize(input) * 3
        client.puts "Ok, next"
      end

      puts "Closing client socket"
      client.close
    end
  end

  private

  def capitalize(text)
    text.upcase
  end
end
