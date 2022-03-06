# frozen_string_literal: true

module EveOnlineHelper
  def create_character
    create(:character).tap do |c|
      allow(c).to receive(:ensure_token_not_expired!)
    end
  end

  def stub_renew_access_token
    stubbed_token = instance_spy(Eve::AccessToken)

    allow(Eve::AccessToken).to receive(:new) do |character|
      if character.refresh_token_voided?
        allow(stubbed_token).to receive(:renew!).and_raise(Eve::AccessToken::Error)
      else
        allow(stubbed_token).to receive(:renew!).and_return(true)
      end

      stubbed_token
    end
  end

  def stub_character_calendar(esi_events)
    instance_spy(EveOnline::ESI::CharacterCalendar).tap do |stub|
      allow(EveOnline::ESI::CharacterCalendar).to receive(:new).and_return(stub)
      allow(stub).to receive(:events).and_return(esi_events)
    end
  end

  def stub_character_calendar_event_not_found
    instance_double(EveOnline::ESI::CharacterCalendarEvent).tap do
      error = EveOnline::Exceptions::ResourceNotFound.allocate
      allow(EveOnline::ESI::CharacterCalendarEvent).to receive(:new).and_raise(error)
    end
  end

  def stub_character_calendar_event(event = Event.new, **rest)
    overwrites = attributes_for(:esi_event_details, **rest)
    instance_double(EveOnline::ESI::CharacterCalendarEvent, **overwrites).tap do |stub|
      allow(stub).to receive(:event_id).and_return(event.uid || overwrites[:event_id])
      allow(EveOnline::ESI::CharacterCalendarEvent).to receive(:new).and_return(stub)
    end
  end
end
