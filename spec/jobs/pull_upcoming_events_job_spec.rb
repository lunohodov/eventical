require "rails_helper"

describe PullUpcomingEventsJob, type: :job do
  it "saves new events" do
    esi_event = build(:esi_event, event_id: 123)

    stub_character_calendar(events: [esi_event])

    PullUpcomingEventsJob.perform_now(character.id)

    expect(Event.find_by(uid: 123)).to be_present
  end

  it "updates existing events" do
    event = create(:event, character: character, uid: 123, title: "old")
    esi_event = build(:esi_event, event_id: 123, title: "new")

    stub_character_calendar(events: [esi_event])

    expect { PullUpcomingEventsJob.perform_now(character.id) }.
      to change { event.reload.title }.
      from("old").
      to("new")
  end

  context "with OAuth error" do
    it "reports an error" do
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
      calendar = stub_character_calendar

      allow(Raven).to receive(:capture_exception)
      allow(calendar).to receive(:events).
        and_raise(EveOnline::Exceptions::ServiceUnavailable)

      PullUpcomingEventsJob.perform_now(character.id)

      expect(Raven).to have_received(:capture_exception)
    end
  end

  def character
    @character ||= create(:character)
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
