class Dummy
  def call(env)
    events = Rack::Utils.parse_query(env['rack.input'].read)['events']
    events = Array(events)

    $stderr.puts "Events count: #{events.count}"
    $stderr.puts "Events: #{events.join(', ')}"
    $stderr.puts '====================================='

    [200, { 'Content-Type' => 'text/plain' }, [events.join(', ')]]
  end
end

run Dummy.new