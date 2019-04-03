require "rails_helper"

describe Eve::Esi do
  describe "configuration" do
    it { is_expected.to respond_to(:configure) }

    it "configures OAuth credentials in initializer" do
      expect(Eve::Esi.config.client_id).not_to be_blank
      expect(Eve::Esi.config.client_secret).not_to be_blank
    end
  end

  describe ".character_calendar" do
    it "returns an event source" do
      character = build(:character)

      result = Eve::Esi.character_calendar(character)

      expect(result).to respond_to(:events)
    end
  end

  describe ".renew_access_token!" do
    it "requests a new access token" do
      oauth_client = instance_spy(OAuth2::Client)
      access_token = instance_spy(
        OAuth2::AccessToken,
        token: "0xNEW", expires_at: 1, refresh_token: "0xNEW_REFRESH",
      )

      allow(oauth_client).to receive(:get_token).and_return(access_token)

      actual_token = Eve::Esi.renew_access_token!(
        "0xREFRESH",
        oauth_client: oauth_client,
      )

      expect(oauth_client).to have_received(:get_token).
        with(refresh_token: "0xREFRESH", grant_type: "refresh_token")
      expect(actual_token.token).to eq("0xNEW")
      expect(actual_token.expires_at).to eq(1)
      expect(actual_token.refresh_token).to eq("0xNEW_REFRESH")
    end
  end
end

describe Eve::Esi::EventSource do
  matcher :be_mapped_from do |source|
    match do |event|
      expect(event.uid).to eq source.event_id
    end
  end

  it "maps ESI event to domain model" do
    character_calendar = instance_double(
      EveOnline::ESI::CharacterCalendar,
      events: [create(:esi_event)],
    )
    events = Eve::Esi::EventSource.new(character_calendar).events
    expect(events.first).to be_mapped_from(character_calendar.events.first)
  end
end