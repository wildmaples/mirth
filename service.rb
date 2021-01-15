require 'socket'
require 'cgi'
require 'uri'

require_relative './http_request'

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
        response_status_code = "200 OK"

        response_message = ""

        response_message << "<ul>\n"
        all_data.each do |daily_data|
          response_message << "<li> On this day <b>#{CGI.escapeHTML(daily_data[:date])}</b>, #{CGI.escapeHTML(daily_data[:step_count])}, #{CGI.escapeHTML(daily_data[:notes])}</li>\n"
        end
        response_message << "</ul>\n"
        response_message << daily_data_form
      when ["POST", "/add/data"]
        content_type = "text/html"
        response_status_code = "201 Created"
        response_message = ""

        headers = HttpRequest.headers(client)
        body = client.read(headers['Content-Length'].to_i)
        
        new_daily_data = URI.decode_www_form(body).to_h
        all_data << new_daily_data.transform_keys(&:to_sym)
      else
        content_type = "text/plain"
        response_status_code = "200 OK"
        response_message =  "✅ Received a #{method_token} request to #{target} with #{version_number} on #{port}"
      end

      puts response_message

      # I hardcoded the Location here for simplicity.
      # It will be refactored later
      http_response = <<~MSG
        #{version_number} #{response_status_code}
        Content-Type: #{content_type}; charset=#{response_message.encoding.name}
        Location: /show/data

        #{response_message}
      MSG

      client.puts http_response

      puts "🛑 Closing client socket"

      client.close
    end
  end

  def daily_data_form
    <<~STR
      <form action="/add/data" method="post" enctype="application/x-www-form-urlencoded">
        <p><label>Date <input type="date" name="date"></label></p>
        <p><label>Step Count <input type="number" name="step_count"></label></p>
        <p><label>Notes <textarea name="notes" rows="5"></textarea></label></p>

        <p><button>Submit daily data</button></p>
      </form>
    STR
  end
end
