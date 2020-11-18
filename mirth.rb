require_relative 'challenges/transform_service'

$stdout.sync = true # Turn on auto-flushing
TransformService.new(1234)
