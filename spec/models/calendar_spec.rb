require "rails_helper"

describe Calendar do
  describe "#agenda" do
    it "includes all upcoming events" do
      character = create(:character)
      events = create_list(
        :event, 2, character: character, starts_at: 1.day.from_now
      )

      agenda = Calendar.new(character).agenda

      expect(agenda.events).to match_array(events)
    end
  end

  describe "#upcoming_events" do
    it "does not return events from other characters" do
      character = create(:character)
      events = [create(:event), create(:event, character: character)]

      returned_events = Calendar.new(character).upcoming_events

      expect(returned_events).not_to include(events.first)
    end

    it "excludes past events" do
      character = create(:character)
      events = [
        create(:event, character: character, starts_at: 1.day.ago),
        create(:event, character: character, starts_at: 1.day.from_now),
      ]

      returned_events = Calendar.new(character).upcoming_events

      expect(returned_events.count).to eq(1)
      expect(returned_events).not_to include(events.first)
    end
  end
end
