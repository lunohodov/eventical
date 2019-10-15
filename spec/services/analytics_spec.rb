require "rails_helper"

describe Analytics do
  let(:analytics_instance) { Analytics.new(character) } # rubocop:disable Metrics/LineLength
  let(:character) { build_stubbed(:character) }

  describe "#track_account_created" do
    it "tracks that a new account was created" do
      analytics_instance.track_account_created

      expect(analytics).to have_tracked("Account created").
        for_character(character).
        with_properties(label: character.name, category: "Accounts")
    end
  end

  describe "#track_access_token_revoked" do
    it "tracks that an access token has been revoked" do
      analytics_instance.track_access_token_revoked

      expect(analytics).to have_tracked("Access token revoked").
        for_character(character).
        with_properties(label: character.name, category: "Calendars")
    end
  end

  describe "#track_refresh_token_voided" do
    it "tracks that ESI‘s refresh token has been voided" do
      analytics_instance.track_refresh_token_voided

      expect(analytics).to have_tracked("Refresh token voided").
        for_character(character).
        with_properties(label: character.name, category: "ESI")
    end
  end

  describe "#track_character_logged_in" do
    it "it tracks that a character logged in" do
      analytics_instance.track_character_logged_in

      expect(analytics).to have_tracked("Logged in").
        for_character(character).
        with_properties(label: character.name, category: "Accounts")
    end
  end

  describe "#track_character_logged_out" do
    it "it tracks that a character logged out" do
      analytics_instance.track_character_logged_out

      expect(analytics).to have_tracked("Logged out").
        for_character(character).
        with_properties(label: character.name, category: "Accounts")
    end
  end

  describe "#track_access_token_used" do
    it "tracks that an access token has been used" do
      access_token = build(:access_token)

      analytics_instance.track_access_token_used(
        access_token,
        consumer: "Google Calendar",
      )

      expect(analytics).to have_tracked("Access token used (Google Calendar)").
        for_character(access_token.grantee).
        with_properties(category: "Calendars", label: access_token.grantee.name)
    end

    context "when expired" do
      it "tracks that an expired access token has been used" do
        access_token = build(:access_token, expires_at: 1.hour.ago)

        analytics_instance.track_access_token_used(
          access_token,
          consumer: "Google",
        )

        expect(analytics).to have_tracked("Expired access token used (Google)").
          for_character(access_token.grantee).
          with_properties(
            category: "Calendars",
            label: access_token.grantee.name,
          )
      end
    end

    context "when revoked" do
      it "tracks that a revoked access token has been used" do
        access_token = build(:access_token, revoked_at: 1.hour.ago)

        analytics_instance.track_access_token_used(
          access_token,
          consumer: "Google",
        )

        expect(analytics).to have_tracked("Revoked access token used (Google)").
          for_character(access_token.grantee).
          with_properties(
            category: "Calendars",
            label: access_token.grantee.name,
          )
      end
    end
  end

  describe "#track_upcoming_events_pulled" do
    it "tracks that upcoming events have been pulled" do
      analytics_instance.track_upcoming_events_pulled

      expect(analytics).to have_tracked("Upcoming events pulled").
        for_character(character).
        with_properties(
          category: "Background jobs",
          label: character.name,
          non_interactive: true,
        )
    end
  end
end
