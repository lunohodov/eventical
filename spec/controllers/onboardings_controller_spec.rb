require "rails_helper"

describe OnboardingsController, type: :controller do
  describe "#show" do
    before { stub_current_character }

    it "renders the view" do
      get :show

      expect(response).to render_template("show")
    end

    it "responds with success" do
      get :show

      expect(response).to have_http_status(:success)
    end

    context "when the current character already has an access token" do
      it "redirects to character's calendar" do
        create(:access_token, character: current_character)

        get :show

        expect(response).to redirect_to(secret_calendar_url)
      end
    end
  end
end
