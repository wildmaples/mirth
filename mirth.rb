require_relative 'service_app'
require 'rack/handler/puma'
require 'active_record'

$stdout.sync = true # Turn on auto-flushing

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "mirth.sqlite3")

app = ServiceApp::Mirth

Rack::Handler::Puma.run(app, :Port => 1234, :Verbose => true)
