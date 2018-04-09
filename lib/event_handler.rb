require_relative 'event_sender'

class EventHandler
  EVENTS_SET = 'events'.freeze
  AVAILABLE_TO_PUSH = 'to_push'.freeze
  BATCH_SIZE_WITHOUT_LAST_EVENT = 9
  LAST_PUSH_KEY = 'last_push'.freeze
  BACKOFF_DURATION = 60 # in seconds

  attr_reader :event

  class << self
    def call(env)
      new(env).call
    end

    def fetch_unpushed_events
      $redis.multi do
        $redis.lrange(AVAILABLE_TO_PUSH, 0, -1)
        $redis.del(AVAILABLE_TO_PUSH)
      end.first
    end
  end

  def initialize(env)
    @event = Rack::Utils.parse_nested_query(env['QUERY_STRING'])['event']
  end

  def call
    push_to_queue_or_send_events if event && push_to_uniq_events_set

    response
  end

  private

  def push_to_queue_or_send_events
    result = push_to_queue_or_trim(event)

    send_to_netcat(result << event) if result.is_a?(Array)
  end

  def push_to_uniq_events_set
    $redis.sadd(EVENTS_SET, event)
  end

  def response
    [200, { 'Content-Type' => 'text/plain' }, ['OK']]
  end

  def push_to_queue_or_trim(event)
    # Script used to ensure atomicity
    # For simplicity reasons EVAL used, better to use SCRIPT LOAD + EVALSHA
    str = <<-EVAL
      local event=KEYS[1];
      local queue=KEYS[2];
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
    EVAL
    $redis.eval(str, [event, AVAILABLE_TO_PUSH])
  end

  # For simplicity just make call to netcat
  # Ideally we can use BLPOP in redis in consumer to read events
  def send_to_netcat(events)
    EventSender.new(events).send_events
  end
end
