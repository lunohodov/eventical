require "rails_helper"

describe Analytics do
  let(:analytics_instance) { Analytics.new(character) } # rubocop:disable Metrics/LineLength
  let(:character) { build_stubbed(:character) }
  let(:analytics) { analytics_instance.backend }

  describe "#track_account_created" do
    it "tracks that a new account was created" do
      analytics_instance.track_account_created

      expect(analytics).to have_tracked("Account created").
        for_character(character).
        with_properties(label: character.name, category: "Accounts")
    end
  end
end
