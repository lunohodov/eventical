require "rails_helper"
require "securerandom"

describe CalendarFeedsController, type: :controller do
  describe "#show" do
    it "notifies analytics than the access token has been used" do
      access_token = create(:access_token)

      request.headers["User-Agent"] = "Google calendar"

      get :show, params: { id: access_token.token }

      expect(analytics).
        to have_tracked("Access token used (Google calendar)")
    end

    it "renders '404 Not Found', when no valid token found" do
      get :show, params: { id: SecureRandom.uuid }

      expect(response.body).to eq("404 Not Found")
    end

    it "notifies Sentry, when no valid token found" do
      bad_token = SecureRandom.uuid
      allow(Raven).to receive(:capture_exception)

      get :show, params: { id: bad_token }

      expect(Raven).to have_received(:capture_exception).with(
        an_instance_of(ActiveRecord::RecordNotFound),
        extra: controller.params.to_unsafe_h,
      )
    end
  end
end
