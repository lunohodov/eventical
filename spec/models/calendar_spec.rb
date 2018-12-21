require "rails_helper"

describe Calendar do
  describe "#agenda_by_date" do
    it "groups events by date" do
      character = create(:character)
      expected = [
        Date.current,
        Date.tomorrow,
      ].map do |date|
        [date, create_list(:event, 2, character: character, starts_at: date)]
      end

      result = Calendar.new(character).agenda_by_date

      expect(result.size).to eq 2
      expect(result.first.date).to eq(expected[0][0])
      expect(result.first.events).to eq(expected[0][1])
      expect(result.last.date).to eq(expected[1][0])
      expect(result.last.events).to eq(expected[1][1])
    end

    it "pads today if there are no events" do
      character = create(:character)
      create(:event, character: character, starts_at: Date.tomorrow)

      result = Calendar.new(character).agenda_by_date

      expect(result.first.date).to eq(Date.today)
      expect(result.first).to be_empty
    end
  end

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

  describe "#empty?" do
    it "returns true when there are no upcoming events" do
      character = create(:character)

      calendar = Calendar.new(character)

      expect(calendar).to be_empty
    end

    it "returns false when there are upcoming events" do
      character = create(:character)
      create(:event, character: character)

      calendar = Calendar.new(character)

      expect(calendar).not_to be_empty
    end
  end
end
