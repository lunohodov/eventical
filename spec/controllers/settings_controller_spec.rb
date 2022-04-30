require "rails_helper"

describe SettingsController, type: :controller do
  describe "#update" do
    it "redirects to :calendar_url" do
      character = create(:character)
      stub_current_character_with(character)

      post :update, params: {time_zone: "Sofia/Europe"}

      expect(response).to redirect_to secret_calendar_url
    end
  end
end
