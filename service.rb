require 'socket'
require 'cgi'

class Service
  def initialize(port)
    server = TCPServer.new(port)

    all_data = [
      { date: '01/01/2021', step_count: '10000', notes: 'This was a good day' },
      { date: '02/01/2021', step_count: '142', notes: 'This was a great day' },
      { date: '03/01/2021', step_count: '68472', notes: 'my favourite HTML tags are <p> and <script>' },
    ]

    loop do
      client = server.accept
      request_line = client.readline
      method_token, target, version_number = request_line.split

      case [method_token, target]
      when ["GET", "/show/data"]
        content_type = "text/html"
        response_message = ""

        response_message << "<ul>\n"
        all_data.each do |daily_data|
          response_message << "<li> On this day <b>#{CGI.escapeHTML(daily_data[:date])}</b>, #{CGI.escapeHTML(daily_data[:step_count])}, #{CGI.escapeHTML(daily_data[:notes])}</li>\n"
        end
        response_message << "</ul>\n"
      else
        response_message =  "✅ Received a #{method_token} request to #{target} with #{version_number} on #{port}"
        content_type = "text/plain"
      end

      puts response_message
      http_response = <<~MSG
        #{version_number} 200 OK
        Content-Type: #{content_type}; charset=#{response_message.encoding.name}

        #{response_message}
      MSG

      client.puts http_response

      puts "🛑 Closing client socket"

      client.close
    end
  end
end
