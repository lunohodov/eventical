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

    expect { PullUpcomingEventsJob.perform_now(character.id) }
      .to change { event.reload.title }
      .from("old")
      .to("new")
  end

  it "deletes removed upcoming events" do
    create(:event, character: character, starts_at: 1.second.from_now)

    stub_character_calendar(events: [])

    expect { PullUpcomingEventsJob.perform_now(character.id) }
      .to change { Event.count }
      .from(1)
      .to(0)
  end

  it "does not delete past events" do
    create(:event, character: character, starts_at: 1.second.ago)

    stub_character_calendar(events: [])

    expect { PullUpcomingEventsJob.perform_now(character.id) }
      .not_to(change { Event.count })
  end

  it "notifies analytics that events have been pulled" do
    create(:event, character: character, starts_at: 1.second.ago)
    stub_character_calendar(events: [])

    PullUpcomingEventsJob.perform_now(character.id)

    expect(analytics).to have_tracked("events.pulled").for_resource(character)
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
