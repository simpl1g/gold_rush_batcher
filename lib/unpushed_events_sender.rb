require_relative 'event_repository'
require_relative 'event_sender'

class UnpushedEventsSender
  def self.send_unpushed
    events = EventRepository.fetch_not_pushed

    EventSender.new(events).send_events unless events.empty?
  end
end
