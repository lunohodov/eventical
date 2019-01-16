require "rails_helper"

describe Event, type: :model do
  describe "validations" do
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:starts_at) }
  end

  describe ".upcoming_for" do
    it "returns future events for given character" do
      character = create(:character)
      events = create_list(
        :event, 2, character: character, starts_at: 1.day.from_now
      )

      result = Event.upcoming_for(character)

      expect(result).to match_array(events)
    end

    context "when there are no upcoming events" do
      it "returns none" do
        character = create(:character)
        create(:event, character: character, starts_at: 1.day.ago)

        result = Event.upcoming_for(character)

        expect(result).to be_empty
      end
    end
  end
end
