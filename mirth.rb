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

  def index
    @all_daily_data = DailyData.all
  end

  def create
    DailyData.create(date: params['date'], step_count: params["step_count"], notes: params["notes"])
    redirect_to(daily_data_path, status: 303)
  end
end

router = ActionDispatch::Routing::RouteSet.new
DailyDataController.include(router.url_helpers)

router.draw do
  resources :daily_data
  match '*path', via: :all, to: 'daily_data#all_paths'
end 

Rack::Handler::Puma.run(router, :Port => 1234, :Verbose => true)
