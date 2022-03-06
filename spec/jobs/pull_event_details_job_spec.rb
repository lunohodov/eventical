require "rails_helper"

describe PullEventDetailsJob, type: :job do
  include EveOnlineHelper

  before do
    stub_renew_access_token
  end

  it "updates importance" do
    event = create(:event, importance: nil, uid: 123)
    stub_character_calendar_event(event, importance: "1")

    expect { PullEventDetailsJob.perform_now(event.uid) }
      .to change { event.reload.importance }.to("1")
  end

  it "updates owner category" do
    event = create(:event, owner_category: nil, uid: 123)
    stub_character_calendar_event(event, owner_type: "character")

    expect { PullEventDetailsJob.perform_now(event.uid) }
      .to change { event.reload.owner_category }.to("character")
  end

  it "updates owner name" do
    event = create(:event, owner_name: nil, uid: 123)
    stub_character_calendar_event(event, owner_name: "abc")

    expect { PullEventDetailsJob.perform_now(event.uid) }
      .to change { event.reload.owner_name }.to("abc")
  end

  it "saves owner uid" do
    event = create(:event, owner_uid: nil, uid: 123)
    stub_character_calendar_event(event, owner_id: 123)

    expect { PullEventDetailsJob.perform_now(event.uid) }
      .to change { event.reload.owner_uid }.to(123)
  end

  it "marks event details as updated" do
    event = create(:event, details_updated_at: nil, uid: 123)
    stub_character_calendar_event(event)

    expect { PullEventDetailsJob.perform_now(event.uid) }
      .to change { event.reload.details_updated_at }.from(nil)
  end

  it "notifies analytics that event details have been pulled" do
    event = create(:event, details_updated_at: nil, uid: 123)
    stub_character_calendar_event(event)

    PullEventDetailsJob.perform_now(event.uid)

    expect(analytics).to have_tracked("character.events").for_resource(event.character)
  end

  context "when ESI can not find the event" do
    it "does not delete existing events" do
      create(:event, uid: 123)
      stub_character_calendar_event_not_found

      expect { PullEventDetailsJob.perform_now(123) }.not_to change { Event.count }
    end
  end

  context "when one of the event owner characters has refresh token voided" do
    it "tries again using the next character" do
      voided_character = create(:character, :with_voided_refresh_token)
      create(:event, character: voided_character, uid: 123)
      active_character = create(:character)
      create(:event, character: active_character, uid: 123)
      stub_character_calendar_event

      PullEventDetailsJob.perform_now(123)

      expect(EveOnline::ESI::CharacterCalendarEvent).not_to have_received(:new).with(
        character_id: voided_character.uid,
        token: voided_character.token,
        event_id: 123
      )

      expect(EveOnline::ESI::CharacterCalendarEvent).to have_received(:new).with(
        character_id: active_character.uid,
        token: active_character.token,
        event_id: 123
      )
    end
  end
end
