require 'net/http'

class EventSender
  attr_reader :events

  def initialize(events)
    @events = events
  end

  def send_events
    Net::HTTP.post_form(netcat_uri, events: events)
  end

  private

  def netcat_uri
    URI("http://#{ENV['NETCAT']}")
  end
end
