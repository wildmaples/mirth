require 'cgi'
require 'rack'
require 'sqlite3'

class ServiceApp
  Mirth = -> environment {
    request = Rack::Request.new(environment)
    response = Rack::Response.new
    database = SQLite3::Database.new("mirth.sqlite3", results_as_hash: true)

    if request.get? && request.path == "/show/data"
      response.write("<ul>\n")
      response.content_type = "text/html; charset=UTF-8"

      all_data = database.execute("SELECT * FROM daily_data")
      
      all_data.each do |daily_data|
        response.write "<li> On this day <b>#{CGI.escapeHTML(daily_data["date"])}</b>, #{CGI.escapeHTML(daily_data["step_count"].to_s)}, #{CGI.escapeHTML(daily_data["notes"])}</li>\n"
      end

      response.write "</ul>\n"
      response.write ServiceApp.daily_data_form

    elsif request.post? && request.path == "/add/data"
      new_daily_data = request.params
      query = "INSERT INTO daily_data (date, step_count, notes) VALUES (?, ?, ?)"
      
      database.execute(query, [new_daily_data['date'], new_daily_data['step_count'].to_i, new_daily_data['notes']])
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
