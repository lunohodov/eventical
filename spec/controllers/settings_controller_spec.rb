require "rails_helper"

describe SettingsController, type: :controller do
  describe "#update" do
    it "redirects to :calendar_url" do
      stub_current_character

      post :update, params: {time_zone: "Sofia/Europe"}

      expect(response).to redirect_to secret_token_url
    end
  end
end
