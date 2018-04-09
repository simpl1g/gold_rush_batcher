require_relative 'lib/redis'
require_relative 'lib/event_app'

# $redis.flushall # Just for testing

app = Rack::Builder.new do
  map '/events' do
    run EventApp
  end
end

run app
