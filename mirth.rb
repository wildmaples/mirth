require_relative 'service_app'
require 'rack/handler/puma'

$stdout.sync = true # Turn on auto-flushing

app = ServiceApp::Mirth

Rack::Handler::Puma.run(app, :Port => 1234, :Verbose => true)
