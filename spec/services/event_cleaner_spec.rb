require "rails_helper"

describe EventCleaner, type: :model do
  describe ".call" do
    it "deletes events older than 6 months" do
      create(:event, title: "left")
      create(:event, title: "older", created_at: 7.months.ago)

      EventCleaner.call
      result = Event.all.map(&:title)

      expect(result).to eq(["left"])
    end

    it "does not delete events belonging to recently deactivated characters" do
      character = create(:character, refresh_token_voided_at: 1.month.ago)
      create(:event, character: character)

      EventCleaner.call

      expect(character.events).not_to be_empty
    end

    it "deletes events belonging to characters deactivated 2 months ago" do
      character = create(:character, refresh_token_voided_at: 2.months.ago)
      create(:event, character: character)

      EventCleaner.call

      expect(character.events).to be_empty
    end

    it "returns the number of deleted events" do
      create(:event, created_at: 7.months.ago)
      create(:event, character: create(:character, refresh_token_voided_at: Time.current))
      create(:event, character: create(:character, refresh_token_voided_at: 2.months.ago))

      result = EventCleaner.call

      expect(result).to eq 2
    end
  end
end
