require 'redis'

$redis = Redis.new(host: ENV['REDIS_MASTER'])
