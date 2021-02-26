require 'action_controller'
require 'action_dispatch'
require 'active_record'
require 'rack/handler/puma'

$stdout.sync = true # Turn on auto-flushing

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "mirth.sqlite3")
ActionController::Base.prepend_view_path(".")

class DailyData < ActiveRecord::Base; end

class DailyDataController < ActionController::Base
  def all_paths
    render(plain: "✅ Received a #{request.request_method} request to #{request.path}!")
  end

  def show_data
    @all_daily_data = DailyData.all
  end

  def add_data
    DailyData.create(date: params['date'], step_count: params["step_count"], notes: params["notes"])
    redirect_to("/show/data", status: 303)
  end
end

router = ActionDispatch::Routing::RouteSet.new

router.draw do
  get '/show/data', to: 'daily_data#show_data'
  post '/add/data', to: 'daily_data#add_data'
  match '*path', via: :all, to: 'daily_data#all_paths'
end 

Rack::Handler::Puma.run(router, :Port => 1234, :Verbose => true)
