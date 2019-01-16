require "rails_helper"

describe Calendar do
  describe "#empty?" do
    it "returns true, with events" do
      events = build_list(:event, 2, character: build(:character))

      calendar = Calendar.new(events: events)

      expect(calendar).not_to be_empty
    end

    it "returns false, without events" do
      calendar = Calendar.new(events: [])

      expect(calendar).to be_empty
    end
  end

  describe "#agenda" do
    it "includes all events" do
      character = build(:character)
      events = build_list(
        :event, 2, character: character, starts_at: 1.day.from_now
      )

      agenda = Calendar.new(events: events).agenda

      expect(agenda.events).to match_array(events)
    end
  end
end
