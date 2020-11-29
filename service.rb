require 'socket'

class Service
  def initialize(port)
    server = TCPServer.new(port)

    loop do
      client = server.accept
      request_line = client.readline
      method_token, target, version_number = request_line.split
      response_message =  "✅ Received a #{method_token} request to #{target} with #{version_number} on #{port}"

      puts response_message

      default_http_response = <<~MSG
        #{version_number} 201 OK
        #{headers.join("\n")}

        #{response_message}
      MSG

      client.puts default_http_response

      puts "🛑 Closing client socket"

      client.close
    end
  end

  def headers
    [
      "Content-Type: text/plain",
    ]
  end
end
