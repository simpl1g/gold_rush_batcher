require 'event_app'

require 'pry'

RSpec.describe EventApp do
  let(:subject) { described_class.new({}) }
  let(:event) { 'event' }
  let(:success_response) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }

  it 'returns success response with empty request' do
    expect(subject.call).to eq(success_response)
  end

  context 'with event passed' do
    before { allow(subject).to receive(:event_message).and_return(event) }

    it 'skips send to netcat if batch is not full' do
      allow(subject).to receive(:save_event).and_return(0)

      expect(subject).to_not receive(:send_to_netcat)

      expect(subject.call).to eq(success_response)
    end

    it 'sends to netcat if batch full' do
      allow(subject).to receive(:save_event).and_return(['event2'])

      expect(subject).to receive(:send_to_netcat).with(['event2', event])

      expect(subject.call).to eq(success_response)
    end
  end
end
