require 'cgi'
require 'uri'
require 'yaml/store'
require 'rack/handler/puma'
require 'rack'

class Service
  def initialize(port)
    app = -> environment {
      method_token = environment['REQUEST_METHOD']
      target = environment['PATH_INFO']
      store = YAML::Store.new("daily_data.yml")

      case [method_token, target]
      when ["GET", "/show/data"]
        content_type = "text/html"
        status = 200
        response_message = "<ul>\n"

        all_data = {}
        store.transaction do
          all_data = store[:all_data]
        end

        all_data.each do |daily_data|
          response_message << "<li> On this day <b>#{CGI.escapeHTML(daily_data[:date])}</b>, #{CGI.escapeHTML(daily_data[:step_count])}, #{CGI.escapeHTML(daily_data[:notes])}</li>\n"
        end

        response_message << "</ul>\n"
        response_message << daily_data_form
      when ["POST", "/add/data"]
        content_type = "text/html"
        status = 303
        response_message = ""

        new_daily_data = URI.decode_www_form(environment["rack.input"].read).to_h

        store.transaction do
          store[:all_data] << new_daily_data.transform_keys(&:to_sym)
        end
      else
        content_type = "text/plain"
        status = 200
        response_message =  "✅ Received a #{method_token} request to #{target}"
      end
          
      headers = { 
        'Content-Type' => "#{content_type}; charset=#{response_message.encoding.name}", 
        "Location" => "/show/data" 
      }
      body = [response_message]
    
      [status, headers, body]
    }

    Rack::Handler::Puma.run(app, :Port => port, :Verbose => true)
  end

  private

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
