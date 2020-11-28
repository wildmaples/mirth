require_relative 'service'

$stdout.sync = true # Turn on auto-flushing
Service.new(1234)
