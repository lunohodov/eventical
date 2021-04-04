require "rails_helper"

describe PullEventDetailsJob, type: :job do
  it "saves importance" do
    event = create(:event, importance: nil)

    stub_renew_access_token
    stub_character_calendar_event(event, importance: "new")

    expect { PullEventDetailsJob.perform_now(event.id) }
      .to change { event.reload.importance }
      .from(nil)
      .to("new")
  end

  it "saves owner category" do
    event = create(:event, owner_category: nil)

    stub_renew_access_token
    stub_character_calendar_event(event, owner_type: "character")

    expect { PullEventDetailsJob.perform_now(event.id) }
      .to change { event.reload.owner_category }
      .from(nil)
      .to("character")
  end

  it "saves owner name" do
    event = create(:event, owner_name: nil)

    stub_renew_access_token
    stub_character_calendar_event(event, owner_name: "new")

    expect { PullEventDetailsJob.perform_now(event.id) }
      .to change { event.reload.owner_name }
      .from(nil)
      .to("new")
  end

  it "saves owner uid" do
    event = create(:event, owner_uid: nil)

    stub_renew_access_token
    stub_character_calendar_event(event, owner_id: 1)

    expect { PullEventDetailsJob.perform_now(event.id) }
      .to change { event.reload.owner_uid }
      .from(nil)
      .to(1)
  end

  it "marks event details as updated" do
    event = create(:event, details_updated_at: nil)

    stub_renew_access_token
    stub_character_calendar_event(event)

    expect { PullEventDetailsJob.perform_now(event.id) }
      .to change { event.reload.details_updated_at }
      .from(nil)
  end

  it "notifies analytics that event details have been pulled" do
    event = create(:event, details_updated_at: nil)
    stub_renew_access_token
    stub_character_calendar_event(event)

    PullEventDetailsJob.perform_now(event.id)

    expect(analytics).to have_tracked("character.events").for_resource(event.character)
  end

  context "with expired access token" do
    it "renews the access token" do
      character = create(:character, token_expires_at: 1.day.ago)
      event = create(:event, character: character)
      renew_token = stub_renew_access_token

      allow(renew_token).to receive(:call)
      stub_character_calendar_event(event)

      PullEventDetailsJob.perform_now(event.id)

      expect(renew_token).to have_received(:call)
    end
  end

  context "when ESI can not find the event" do
    it "deletes the event" do
      event = create(:event)
      calendar_event = stub_character_calendar_event(event)

      allow(calendar_event)
        .to receive(:owner_name)
        .and_raise(EveOnline::Exceptions::ResourceNotFound.allocate)

      expect { PullEventDetailsJob.perform_now(event.id) }
        .to change { Event.count }
        .from(1)
        .to(0)
    end
  end

  def stub_renew_access_token
    instance_spy(Eve::RenewAccessToken).tap do |t|
      allow(Eve::RenewAccessToken).to receive(:new).and_return(t)
    end
  end

  def stub_character_calendar_event(event, **attrs)
    stub = instance_double(EveOnline::ESI::CharacterCalendarEvent)

    allow(stub).to receive(:owner_id).and_return(attrs[:owner_id])
    allow(stub).to receive(:owner_name).and_return(attrs[:owner_name])
    allow(stub).to receive(:owner_type).and_return(attrs[:owner_type])
    allow(stub).to receive(:importance).and_return(attrs[:importance])

    allow(EveOnline::ESI::CharacterCalendarEvent)
      .to receive(:new)
      .with(character_id: event.character.uid,
            event_id: event.uid,
            token: event.character.token)
      .and_return(stub)

    stub
  end
end
