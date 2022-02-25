require "rails_helper"

describe CharacterEvents::Remote, type: :model do
  include EveOnlineHelper

  let(:character) { create_character }

  it "enumerates event entries" do
    esi_events = [1, 3].map { |id| build(:esi_event, event_id: id) }
    stub_character_calendar(esi_events)

    events = CharacterEvents::Remote.new(character)
    result = events.map(&:uid)

    expect(result).to eq [1, 3]
  end

  it "ensures character's token not expired" do
    stub_character_calendar([])

    CharacterEvents::Remote.new(character).map(&:uid)

    expect(character).to have_received(:ensure_token_not_expired!)
  end

  describe ".eager" do
    it "loads event entries eagerly" do
      character_calendar = stub_character_calendar([])

      CharacterEvents::Remote.eager(character)

      expect(character_calendar).to have_received(:events)
    end
  end
end
