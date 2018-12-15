require "rails_helper"

describe Calendar do
  describe "#upcoming_events" do
    it "includes events starting today and beyond" do
      character = create(:character)
      events = [
        1.day.ago,
        Date.current.midnight.advance(seconds: -1),
        Date.current,
        Date.current.midday,
        Date.tomorrow,
        1.day.from_now,
      ].map do |starts_at|
        create(:event, character: character, starts_at: starts_at)
      end

      upcoming_events = Calendar.new(character).upcoming_events

      expect(upcoming_events).to match_array(events[2..-1])
    end

    it "returns sorted events (older first)" do
      character = create(:character)
      events = [
        Date.current.midday,
        Date.tomorrow,
        Date.current,
      ].map do |starts_at|
        create(:event, character: character, starts_at: starts_at)
      end

      upcoming_events = Calendar.new(character).upcoming_events

      expect(upcoming_events).to match_array(events.sort_by(&:starts_at))
    end
  end
end
