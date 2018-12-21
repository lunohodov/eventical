require "rails_helper"

describe CalendarFeedsController, type: :controller do
  describe "#show" do
    before do
      event = create(:event)
      stub_current_character_with(event.character)
    end

    it "has a HTTP OK status" do
      access_token = stub_access_token

      get :show, params: { id: access_token.token }

      expect(response).to have_http_status(:ok)
    end

    it "responds with cache headers" do
      access_token = stub_access_token

      get :show, params: { id: access_token.token }

      expect(response.headers["Cache-Control"]).to eq "no-cache, no-store"
      expect(response.headers["Pragma"]).to eq "no-cache"
      expect(response.headers["Expires"]).to eq(Time.utc(1990, 1, 1).rfc2822)
      expect(response.headers["Date"]).to be_present
    end

    it "responds with content headers" do
      access_token = stub_access_token

      get :show, params: { id: access_token.token }

      expect(response.headers["Content-Type"]).to eq "text/html; charset=utf-8"
    end

    it "responds with '404 Not found' when access token is invalid" do
      access_token = create(:access_token)

      get :show, params: { id: access_token.token }

      expect(response).to have_http_status(:not_found)
    end

    def stub_access_token(grantee: nil)
      # FIXME: Don't call private methods
      issuer = controller.send(:current_character)

      create(
        :access_token,
        issuer: issuer,
        grantee: grantee.presence || issuer,
      )
    end
  end
end
