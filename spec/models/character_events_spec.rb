require "rails_helper"

describe CharacterEvents, type: :model do
  let(:character) { create(:character) }
  let(:stubbed_remote) { instance_spy(CharacterEvents::Remote) }
  let(:stubbed_replacement) { instance_spy(CharacterEvents::Replacement) }

  describe "#pull" do
    before do
      allow(CharacterEvents::Remote).to receive(:eager).and_return(stubbed_remote)
      allow(CharacterEvents::Replacement).to receive(:new).and_return(stubbed_replacement)
    end

    it "eager loads character's remote events" do
      CharacterEvents.new(character).pull

      expect(CharacterEvents::Remote).to have_received(:eager).with(character)
    end

    it "replaces character's existing events" do
      CharacterEvents.new(character).pull

      expect(stubbed_replacement).to have_received(:call)
    end

    it "updates character's event pull timestamp" do
      allow(stubbed_replacement).to receive(:call).and_yield

      expect { CharacterEvents.new(character).pull }
        .to change { character.reload.last_event_pull_at }
    end
  end

  describe "#replace" do
    it "replaces character's existing events" do
      allow(CharacterEvents::Replacement).to receive(:new).and_return(stubbed_replacement)
      events = [1, 2].map { |uid| build(:event, uid: uid, character: character) }

      CharacterEvents.new(character).replace(events)

      expect(CharacterEvents::Replacement).to have_received(:new).with(character, events)
      expect(stubbed_replacement).to have_received(:call)
    end
  end
end
