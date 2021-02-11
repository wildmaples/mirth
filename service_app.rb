require 'cgi'
require 'rack'
require 'active_record'

class DailyData < ActiveRecord::Base; end

class ServiceApp
  Mirth = -> environment {
    request = Rack::Request.new(environment)
    response = Rack::Response.new
    
    if request.get? && request.path == "/show/data"
      response.write("<ul>\n")
      response.content_type = "text/html; charset=UTF-8"
      
      DailyData.all.each do |daily_data|
        response.write "<li> On this day <b>#{CGI.escapeHTML(daily_data.date)}</b>, #{CGI.escapeHTML(daily_data.step_count.to_s)}, #{CGI.escapeHTML(daily_data.notes)}</li>\n"
      end

      response.write "</ul>\n"
      response.write ServiceApp.daily_data_form

    elsif request.post? && request.path == "/add/data"
      params = request.params
      DailyData.create(date: params['date'], step_count: params["step_count"], notes: params["notes"])
      response.redirect('/show/data', 303)
    else
      response.content_type = "text/plain; charset=UTF-8"
      response.write("✅ Received a #{request.request_method} request to #{request.path}!")
    end
        
    response.finish
  }

  def self.daily_data_form
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
