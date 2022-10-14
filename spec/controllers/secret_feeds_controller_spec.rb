require "rails_helper"

describe SecretFeedsController, type: :controller do
  before { request.headers["User-Agent"] = "Google" }

  describe "GET :show" do
    it "notifies analytics that the access token has been used" do
      access_token = create(:private_access_token)

      get :show, params: {id: access_token.token}

      expect(analytics)
        .to have_tracked("access_token.used").for_resource(access_token)
    end

    it "renders '404 Not Found', when token can not be found" do
      get :show, params: {id: SecureRandom.uuid}

      expect(response).to have_http_status :not_found
    end

    it "renders '404 Not Found', when token is not private" do
      access_token = create(:access_token, :public)

      get :show, params: {id: access_token.token}

      expect(response).to have_http_status :not_found
    end

    it "renders '404 Not Found', when token is revoked" do
      access_token = create(:private_access_token, revoked_at: 1.hour.ago)

      get :show, params: {id: access_token.token}

      expect(response).to have_http_status :not_found
      expect(analytics)
        .to have_tracked("access_token.revoked.used").for_resource(access_token)
    end
  end
end
