class EventRepository
  EVENTS_SET = 'events'.freeze
  AVAILABLE_TO_PUSH = 'to_push'.freeze
  BATCH_SIZE_WITHOUT_LAST_EVENT = 9
  LAST_PUSH_KEY = 'last_push'.freeze
  BACKOFF_DURATION = 60 # in seconds

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def self.fetch_not_pushed
    $redis.multi do
      $redis.lrange(AVAILABLE_TO_PUSH, 0, -1)
      $redis.del(AVAILABLE_TO_PUSH)
    end.first
  end

  def save
    # Script used to ensure atomicity
    # For simplicity reasons EVAL used, better to use SCRIPT LOAD + EVALSHA
    str = <<-EVAL
    local event=KEYS[1];
    local queue='#{AVAILABLE_TO_PUSH}';
    if redis.call('sadd', '#{EVENTS_SET}', event) == 1 then
      local length=redis.call('llen', queue);
      if length >= #{BATCH_SIZE_WITHOUT_LAST_EVENT} then
        local events = redis.call('lrange', queue, 0, #{BATCH_SIZE_WITHOUT_LAST_EVENT - 1});
        redis.call('ltrim', queue, #{BATCH_SIZE_WITHOUT_LAST_EVENT}, -1);
        return events;
      else
        redis.call('rpush', queue, event);
        redis.call('setex', '#{LAST_PUSH_KEY}', #{BACKOFF_DURATION}, 'value');
        return 0;
      end
    else
      return 0;
    end
    EVAL
    $redis.eval(str, [message])
  end
end