require "rails_helper"

describe CalendarsController, type: :controller do
  before { stub_current_character }

  describe "#show" do
    it "renders the view" do
      create(:access_token, :personal, issuer: current_character)

      get :show

      expect(response).to render_template("show")
    end

    context "without a personal access token" do
      it "renders an empty state view" do
        get :show

        expect(response).to render_template("onboarding")
      end
    end
  end
end
