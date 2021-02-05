require 'cgi'
require 'yaml/store'
require 'rack/handler/puma'
require 'rack'

class Service
  def initialize(port)
    app = -> environment {
      request = Rack::Request.new(environment)
      response = Rack::Response.new
      store = YAML::Store.new("daily_data.yml")

      if request.get? && request.path == "/show/data"
        response.write("<ul>\n")
        response.content_type = "text/html; charset=UTF-8"

        all_data = {}
        store.transaction do
          all_data = store[:all_data]
        end

        all_data.each do |daily_data|
          response.write "<li> On this day <b>#{CGI.escapeHTML(daily_data[:date])}</b>, #{CGI.escapeHTML(daily_data[:step_count])}, #{CGI.escapeHTML(daily_data[:notes])}</li>\n"
        end

        response.write "</ul>\n"
        response.write daily_data_form

      elsif request.post? && request.path == "/add/data"
        new_daily_data = request.params.transform_keys(&:to_sym)
        store.transaction do
          store[:all_data] << new_daily_data
        end

        response.redirect('/show/data', 303)
      
      else
        response.content_type = "text/plain; charset=UTF-8"
        response.write("✅ Received a #{request.request_method} request to #{request.path}!")
      end
          
      response.finish
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
