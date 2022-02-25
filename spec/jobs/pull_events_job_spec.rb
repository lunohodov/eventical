require "rails_helper"

describe PullEventsJob, type: :job do
  include EveOnlineHelper

  let(:character) { create_character }

  before do
    allow(Character).to receive(:find).and_return(character)
  end

  it "pulls character events" do
    esi_events = [1, 2].map { |id| build(:esi_event, event_id: id) }
    stub_character_calendar(esi_events)

    PullEventsJob.perform_now(character.id)

    expect(Event.where(uid: [1, 2]).count).to eq 2
  end

  it "tracks pull in analytics" do
    stub_character_calendar([])

    PullEventsJob.perform_now(character.id)

    expect(analytics).to have_tracked("events.pulled").for_resource(character)
  end

  context "when character's refresh token is voided" do
    before do
      allow(character).to receive(:refresh_token_voided?).and_return(true)
    end

    it "does not pull events" do
      PullEventsJob.perform_now(character.id)

      expect(Event.count).to be_zero
    end

    it "does not track in analytics" do
      PullEventsJob.perform_now(character.id)

      expect(analytics).not_to have_tracked("events.pulled")
    end
  end
end
