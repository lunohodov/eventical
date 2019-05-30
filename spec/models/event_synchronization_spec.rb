require "rails_helper"

describe EventSynchronization do
  describe "initialization" do
    it "uses ESI's character calendar, when no source given" do
      character = build(:character)

      allow(Eve::Esi).to receive(:character_calendar)

      EventSynchronization.new(character: character)

      expect(Eve::Esi).to have_received(:character_calendar).with(character)
    end
  end

  describe "#call" do
    it "fetches events from specified source" do
      character = build(:character)
      source = stub_event_source

      EventSynchronization.new(character: character, source: source).call

      expect(source).to have_received(:events)
    end

    it "does not initiate a transaction when the source yields no events" do
      character = build(:character)
      source = stub_event_source([])

      allow(Event).to receive(:transaction)

      result = EventSynchronization.new(character: character, source: source).
        call

      expect(Event).not_to have_received(:transaction)
      expect(result).to be_empty
    end

    it "saves new event" do
      character = create(:character)
      new_event = build(:event, character: character)
      source = stub_event_source([new_event])

      result = EventSynchronization.new(character: character, source: source).
        call

      expect(Event.find_by(uid: new_event.uid)).to be_present
      expect(result.size).to eq 1
    end

    it "updates title of existing event" do
      character = create(:character)
      event = create(:event, character: character, title: "old")
      source = stub_event_source(
        [
          build(:event, uid: event.uid, title: "new"),
        ],
      )

      expect do
        EventSynchronization.new(character: character, source: source).call
      end.to change { event.reload.title }.from("old").to("new")
    end

    it "updates time of existing event" do
      character = create(:character)
      event = create(:event, character: character, starts_at: Time.at(0))
      source = stub_event_source([build(:event, uid: event.uid)])

      expect do
        EventSynchronization.new(character: character, source: source).call
      end.to change { event.reload.starts_at }.from(Time.at(0))
    end

    it "updates response of existing event" do
      character = create(:character)
      event = create(:event, character: character, response: :attending)
      source = stub_event_source(
        [build(:event, uid: event.uid, response: :tentative)],
      )

      expect do
        EventSynchronization.new(character: character, source: source).call
      end.to change { event.reload.response }.from("attending").to("tentative")
    end

    it "updates importance of existing event" do
      character = create(:character)
      event = create(:event, character: character, importance: "low")
      source = stub_event_source(
        [build(:event, uid: event.uid, importance: "high")],
      )

      expect do
        EventSynchronization.new(character: character, source: source).call
      end.to change { event.reload.importance }.from("low").to("high")
    end

    def stub_event_source(events = [])
      double("event_source", events: events)
    end
  end
end
