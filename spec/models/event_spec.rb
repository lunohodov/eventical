require "rails_helper"

describe Event, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to(Time.current)
  end

  after do
    travel_back
  end

  describe "validations" do
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:character_owner_hash) }
    it { should allow_value(nil).for(:owner_category) }
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

    context "when the :since argument is nil" do
      it "uses current date" do
        character = create(:character)
        create(:event, character: character, starts_at: 1.day.from_now)
        create(:event, character: character, starts_at: 1.day.ago)

        result = Event.upcoming_for(character)

        expect(result.to_a)
          .to eq(Event.where("starts_at >= ?", Date.current).to_a)
      end
    end
  end

  describe ".synchronize" do
    it "saves new event" do
      data_source = build(:event, character: character)

      Event.synchronize(data_source)

      expect(Event.find_by(uid: data_source.uid).attributes)
        .to include(data_source.attributes.slice(:title, :starts_at, :response))
    end

    context "when event exists" do
      it "updates response" do
        event = create(:event, character: character)
        data_source = build(
          :event, character: character, uid: event.uid, response: "new"
        )

        expect { Event.synchronize(data_source) }
          .to change { event.reload.response }
          .to "new"
      end

      it "updates owner_uid" do
        event = create(:event, character: character, owner_uid: nil)
        data_source = build(
          :event, character: character, uid: event.uid, owner_uid: 123_456
        )

        expect { Event.synchronize(data_source) }
          .to change { event.reload.owner_uid }
          .to 123_456
      end

      it "updates owner_category" do
        event = create(:event, character: character, owner_category: nil)
        data_source = build(
          :event,
          character: character,
          uid: event.uid,
          owner_category: "character"
        )

        expect { Event.synchronize(data_source) }
          .to change { event.reload.owner_category }
          .to "character"
      end

      it "updates owner_name" do
        event = create(:event, character: character, owner_name: nil)
        data_source = build(
          :event, character: character, uid: event.uid, owner_name: "new"
        )

        expect { Event.synchronize(data_source) }
          .to change { event.reload.owner_name }
          .to "new"
      end

      it "updates title" do
        event = create(:event, character: character)
        data_source = build(
          :event, character: character, uid: event.uid, title: "new"
        )

        expect { Event.synchronize(data_source) }
          .to change { event.reload.title }
          .to "new"
      end

      it "updates importance" do
        event = create(:event, character: character, importance: nil)
        data_source = build(
          :event,
          character: character,
          uid: event.uid,
          importance: "new"
        )

        expect { Event.synchronize(data_source) }
          .to change { event.reload.importance }
          .to "new"
      end

      it "updates start time" do
        event = create(:event, character: character, starts_at: Time.utc(2000))
        data_source = build(
          :event,
          character: character,
          uid: event.uid,
          starts_at: Time.utc(2001)
        )

        expect { Event.synchronize(data_source) }
          .to change { event.reload.starts_at }
          .to Time.utc(2001)
      end
    end

    def character
      @character ||= create(:character)
    end
  end
end
