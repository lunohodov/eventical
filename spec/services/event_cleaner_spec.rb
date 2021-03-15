require "rails_helper"

describe EventCleaner, type: :model do
  describe "#call" do
    it "does not delete events happening in the future (minus 1 week)" do
      create(:event, title: "3 days ago", starts_at: 3.days.ago)
      create(:event, title: "Today", starts_at: Time.current)
      create(:event, title: "Next week", starts_at: 1.week.from_now)

      EventCleaner.new.call
      events_left = Event.pluck(:title)

      expect(events_left).to match_array(["3 days ago", "Today", "Next week"])
    end

    it "deletes events happened over 1 week ago" do
      create(:event, title: "left")
      create(:event, title: "deleted", starts_at: 8.days.ago)

      EventCleaner.new.call
      events_left = Event.pluck(:title)

      expect(events_left).to eq(["left"])
    end

    it "deletes events owned by voided characters" do
      character = create(:character, refresh_token_voided_at: Time.current)
      create(:event, character: character, starts_at: 1.day.from_now)
      create(:event, character: character, starts_at: Time.current)

      EventCleaner.new.call

      expect(character.reload.events).to be_empty
    end

    it "returns the number of deleted events" do
      create(:event, starts_at: 2.weeks.ago)
      create(:event, character: create(:character, refresh_token_voided_at: Time.current))
      create(:event)

      result = EventCleaner.new.call

      expect(result).to eq 2
    end
  end
end
