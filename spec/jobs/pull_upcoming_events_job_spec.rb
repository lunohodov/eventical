require "rails_helper"

describe PullUpcomingEventsJob, type: :job do
  it "saves new events" do
    character = create(:character)
    new_event = build(:esi_event)

    stub_renew_access_token
    stub_character_calendar(events: [new_event])

    PullUpcomingEventsJob.perform_now(character.id)

    expect(Event.find_by(uid: new_event.event_id)).to be_present
  end

  it "updates existing events" do
    character = create(:character)
    event = create(:event, character: character)
    esi_event = build(:esi_event, event_id: event.uid, title: "new text")

    stub_renew_access_token
    stub_character_calendar(events: [esi_event])

    expect { PullUpcomingEventsJob.perform_now(character.id) }.
      to change { event.reload.title }.
      to "new text"
  end

  context "with OAuth error" do
    it "reports an error" do
      character = create(:character)

      stub_character_calendar
      renew_token = stub_renew_access_token

      allow(Raven).to receive(:capture_exception)
      allow(renew_token).to receive(:call).and_raise(OAuth2::Error)

      PullUpcomingEventsJob.perform_now(character.id)

      expect(Raven).to have_received(:capture_exception)
    end
  end

  context "when ESI is not available" do
    it "reports an error" do
      character = create(:character)
      calendar = stub_character_calendar

      allow(Raven).to receive(:capture_exception)
      allow(calendar).to receive(:events).
        and_raise(EveOnline::Exceptions::ServiceUnavailable)

      PullUpcomingEventsJob.perform_now(character.id)

      expect(Raven).to have_received(:capture_exception)
    end
  end

  def stub_character_calendar(events: nil)
    instance_spy(EveOnline::ESI::CharacterCalendar).tap do |c|
      allow(EveOnline::ESI::CharacterCalendar).to receive(:new).and_return(c)
      allow(c).to receive(:events).and_return(events) if events
    end
  end

  def stub_renew_access_token
    instance_spy(Eve::RenewAccessToken).tap do |t|
      allow(Eve::RenewAccessToken).to receive(:new).and_return(t)
    end
  end
end
