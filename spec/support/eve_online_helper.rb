# frozen_string_literal: true

module EveOnlineHelper
  def create_character
    create(:character).tap do |c|
      allow(c).to receive(:ensure_token_not_expired!)
    end
  end

  def stub_character_calendar(esi_events)
    instance_spy(EveOnline::ESI::CharacterCalendar).tap do |stub|
      allow(EveOnline::ESI::CharacterCalendar).to receive(:new).and_return(stub)
      allow(stub).to receive(:events).and_return(esi_events)
    end
  end
end
