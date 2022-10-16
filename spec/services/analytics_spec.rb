require "rails_helper"

describe Analytics do
  describe "#track_access_token_revoked" do
    it "tracks that an access token has been revoked" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      access_token = build_stubbed(:access_token)

      analytics_instance.track_access_token_revoked(access_token)

      expect(analytics_instance.backend)
        .to have_tracked("access_token.revoked").for_resource(access_token.character).times(1)
    end
  end

  describe "#track_refresh_token_voided" do
    it "tracks that ESI‘s refresh token has been voided" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      character = build_stubbed(:character)

      analytics_instance.track_refresh_token_voided(character)

      expect(analytics_instance.backend)
        .to have_tracked("esi.refresh_token.revoked").for_resource(character)
    end
  end

  describe "#track_character_logged_in" do
    it "it tracks that a character logged in" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      character = build_stubbed(:character)

      analytics_instance.track_character_logged_in(character)

      expect(analytics_instance.backend)
        .to have_tracked("character.logged_in").for_resource(character)
    end
  end

  describe "#track_character_logged_out" do
    it "it tracks that a character logged out" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      character = build_stubbed(:character)

      analytics_instance.track_character_logged_out(character)

      expect(analytics_instance.backend)
        .to have_tracked("character.logged_out").for_resource(character)
    end
  end

  describe "#track_access_token_used" do
    it "tracks that an access token has been used" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      access_token = build_stubbed(:access_token)

      analytics_instance.track_access_token_used(access_token)

      expect(analytics_instance.backend)
        .to have_tracked("access_token.used").for_resource(access_token)
    end

    it "tracks that a revoked access token has been used" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      access_token = build_stubbed(:access_token, revoked_at: 1.hour.ago)

      analytics_instance.track_access_token_used(access_token)

      expect(analytics_instance.backend)
        .to have_tracked("access_token.revoked.used").for_resource(access_token)
    end
  end

  describe "#track_upcoming_events_pulled" do
    it "tracks that upcoming events have been pulled" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      character = build_stubbed(:character)

      analytics_instance.track_upcoming_events_pulled(character)

      expect(analytics_instance.backend)
        .to have_tracked("events.pulled").for_resource(character)
    end
  end

  describe "#track_event_details_pulled" do
    it "tracks that event details have been pulled" do
      analytics_instance = Analytics.new(backend: Analytics::InMemoryBackend.new)
      character = build_stubbed(:character)

      analytics_instance.track_event_details_pulled(character)

      expect(analytics_instance.backend)
        .to have_tracked("character.events").for_resource(character)
    end
  end
end
