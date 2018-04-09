require_relative 'event_repository'
require_relative 'event_sender'

class EventApp
  attr_reader :event_message

  def self.call(env)
    new(env).call
  end

  def initialize(env)
    @event_message = Rack::Utils.parse_nested_query(env['QUERY_STRING'])['event']
  end

  def call
    push_to_queue_and_send_events if event_message

    response
  end

  private

  def push_to_queue_and_send_events
    result = save_event

    send_to_netcat(result << event_message) if result.is_a?(Array)
  end

  def save_event
    EventRepository.new(event_message).save
  end

  def response
    [200, { 'Content-Type' => 'text/plain' }, ['OK']]
  end

  # For simplicity just make call to netcat
  # Ideally we need to use BLPOP in redis in consumer to read events
  # and be able to retry if netcat is down
  def send_to_netcat(events)
    EventSender.new(events).send_events
  end
end
