require 'action_dispatch'
require 'active_record'
require 'cgi'
require 'rack'
require 'rack/charset'
require 'rack/handler/puma'

$stdout.sync = true # Turn on auto-flushing

class DailyData < ActiveRecord::Base; end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "mirth.sqlite3")

router = ActionDispatch::Routing::RouteSet.new

router.draw do
  get '/show/data', to: -> environment {
    request = Rack::Request.new(environment)
    response = Rack::Response.new

    response.write("<ul>\n")
    response.content_type = "text/html"
    
    DailyData.all.each do |daily_data|
      response.write "<li> On this day <b>#{CGI.escapeHTML(daily_data.date)}</b>, #{CGI.escapeHTML(daily_data.step_count.to_s)}, #{CGI.escapeHTML(daily_data.notes)}</li>\n"
    end

    response.write "</ul>\n"
    response.write daily_data_form
    response.finish
  }

  post '/add/data', to: -> environment {
    request = Rack::Request.new(environment)
    response = Rack::Response.new
    params = request.params
    DailyData.create(date: params['date'], step_count: params["step_count"], notes: params["notes"])
    response.redirect('/show/data', 303)
    response.finish
  }

  match '*path', via: :all, to: -> environment {
    request = Rack::Request.new(environment)
    response = Rack::Response.new  
    response.content_type = "text/plain"
    response.write("✅ Received a #{request.request_method} request to #{request.path}!")
    response.finish
  }

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

app_with_charset = Rack::Charset.new(router, 'utf-8')
Rack::Handler::Puma.run(app_with_charset, :Port => 1234, :Verbose => true)
