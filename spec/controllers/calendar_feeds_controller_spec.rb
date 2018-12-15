require "rails_helper"

describe CalendarFeedsController, type: :controller do
  describe "#show" do
    before { create(:event) }

    it "has a HTTP OK status" do
      token = build(:calendar_access_token)

      get :show, params: { id: token.value }

      expect(response).to have_http_status(:ok)
    end

    it "responds with cache headers" do
      token = build(:calendar_access_token)

      get :show, params: { id: token.value }

      expect(response.headers["Cache-Control"]).to eq "no-cache, no-store"
      expect(response.headers["Pragma"]).to eq "no-cache"
      expect(response.headers["Expires"]).to eq(Time.utc(1990, 1, 1).rfc2822)
      expect(response.headers["Date"]).to be_present
    end

    it "responds with content headers" do
      token = build(:calendar_access_token)

      get :show, params: { id: token.value }

      expect(response.headers["Content-Type"]).to eq "text/html; charset=utf-8"
    end

    context "with :ical format" do
      it "responds with content headers" do
        token = build(:calendar_access_token)

        get :show, params: { id: token.value, format: :ical }

        expect(response.headers["Content-Type"]).to eq "text/calendar; charset=utf-8"
        expect(response.headers["Content-Transfer-Encoding"]).to eq "binary"
        expect(response.headers["Content-Disposition"]).
          to match(/^inline; filename=.*/i)
      end
    end
  end
end
