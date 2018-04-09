require_relative 'lib/redis'
require_relative 'lib/event_handler'

# $redis.flushall # Just for testing

app = Rack::Builder.new do
  map '/events' do
    run EventHandler
  end
end

run app
