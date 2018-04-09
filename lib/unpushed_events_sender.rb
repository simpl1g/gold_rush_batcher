require_relative 'event_handler'

class UnpushedEventsSender
  def self.send_unpushed
    events = EventHandler.fetch_unpushed_events

    EventSender.new(events).send_events unless events.empty?
  end
end
