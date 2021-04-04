require "rails_helper"
require "securerandom"

describe CalendarFeedsController, type: :controller do
  before { request.headers["User-Agent"] = "Google" }

  describe "#show" do
    it "notifies analytics that the access token has been used" do
      access_token = create(:access_token)

      get :show, params: {id: access_token.token}

      expect(analytics)
        .to have_tracked("access_token.used").for_resource(access_token)
    end

    it "renders '404 Not Found', when token can not be found" do
      get :show, params: {id: SecureRandom.uuid}

      expect(response.body).to eq("404 Not Found")
    end

    it "renders '404 Not Found', when token is expired" do
      access_token = create(:access_token, expires_at: 1.hour.ago)

      get :show, params: {id: access_token.token}

      expect(response.body).to eq("404 Not Found")
      expect(analytics)
        .to have_tracked("access_token.expired.used").for_resource(access_token)
    end

    it "renders '404 Not Found', when token is revoked" do
      access_token = create(:access_token, revoked_at: 1.hour.ago)

      get :show, params: {id: access_token.token}

      expect(response.body).to eq("404 Not Found")
      expect(analytics)
        .to have_tracked("access_token.revoked.used").for_resource(access_token)
    end
  end
end
