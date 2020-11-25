require 'socket'

class TransformService
  def initialize(port)
    server = TCPServer.new(port)

    loop do
      client = server.accept
      request_line = client.readline
      method_token, target, version_number = request_line.split

      puts "✅ Received a #{method_token} request to #{target} with #{version_number} on #{port}"
      puts "🛑 Closing client socket"
      client.close
    end
  end
end
