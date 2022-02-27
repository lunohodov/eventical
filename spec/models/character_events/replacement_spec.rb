require "rails_helper"

describe CharacterEvents::Replacement, type: :model do
  let(:character) { create(:character) }

  it "creates new events" do
    events = [build(:event, character: character, uid: 123)]
    replacement = CharacterEvents::Replacement.new(character, events)

    replacement.call

    expect(Event.find_by(uid: 123)).to be_present
  end

  it "updates existing events" do
    event =
      create(:event, character: character, uid: 123, title: "Old")
        .tap { _1.title = "New" }
    replacement = CharacterEvents::Replacement.new(character, [event])

    replacement.call
    event.reload

    expect(event.title).to eq "New"
    expect(event.updated_at > event.created_at).to be_truthy
  end

  it "deletes obsolete events" do
    create(:event, character: character, uid: 123)
    events = [build(:event, character: character, uid: 456)]
    replacement = CharacterEvents::Replacement.new(character, events)

    replacement.call

    expect(Event.find_by(uid: 123)).not_to be_present
  end

  it "keeps past events" do
    create(:event, character: character, uid: 456, starts_at: 1.hour.ago)
    replacement = CharacterEvents::Replacement.new(character, [])

    replacement.call

    expect(Event.find_by(uid: 456)).to be_present
  end

  describe "character scoping" do
    let(:other_character) { create(:character) }

    it "does not create events for other character" do
      events = [
        build(:event, character: character, uid: 123),
        build(:event, character: other_character, uid: 123)
      ]
      replacement = CharacterEvents::Replacement.new(character, events)

      replacement.call

      expect(other_character.events).to be_blank
    end

    it "does not update other character's events" do
      event = create(:event, character: character, uid: 123).tap { _1.title = "123" }
      other_event = create(:event, character: other_character, uid: 123)
      replacement = CharacterEvents::Replacement.new(character, [event, other_event])

      replacement.call

      expect(other_event.reload.title).not_to eq "123"
    end

    it "does not delete other character's events" do
      create(:event, character: other_character, uid: 123)
      create(:event, character: character, uid: 123)
      replacement = CharacterEvents::Replacement.new(character, [])

      replacement.call

      expect(character.events.count).to eq 0
      expect(other_character.events.count).to eq 1
    end
  end
end
