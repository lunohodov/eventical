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

    it "deletes events belonging to deactivated characters" do
      active_character = create(:character)
      deactivated_character = create(:character, :with_voided_refresh_token)
      create(:event, character: active_character)
      create(:event, character: deactivated_character)

      EventCleaner.call

      expect(active_character.events).not_to be_empty
      expect(deactivated_character.events).to be_empty
    end

    it "returns the number of deleted events" do
      create(:event, created_at: 7.months.ago)
      create(:event, character: create(:character, :with_voided_refresh_token))

      result = EventCleaner.call

      expect(result).to eq 2
    end
  end
end
