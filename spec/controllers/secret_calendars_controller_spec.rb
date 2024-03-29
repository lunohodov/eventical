require "rails_helper"

describe SecretCalendarsController, type: :controller do
  before { stub_current_character }

  describe "#show" do
    it "renders the view" do
      create(:access_token, character: current_character)

      get :show

      expect(response).to render_template("show")
    end

    context "without a personal access token" do
      it "redirects to onboarding" do
        get :show

        expect(response).to redirect_to(onboarding_path)
      end
    end
  end
end
