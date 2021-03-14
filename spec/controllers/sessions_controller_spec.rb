require "rails_helper"

describe SessionsController, type: :controller do
  include StubCurrentCharacterHelper

  before { ActiveJob::Base.queue_adapter = :test }

  context "#create" do
    it "redirects to calendar path" do
      stub_valid_oauth_hash

      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:eve_online_sso]
      request.env["omniauth.origin"] = nil

      get :create, params: {provider: "eve_online_sso"}

      should redirect_to(calendar_url)

      expect(analytics).to have_tracked("Logged in")
    end

    it "does not redirect to an outside domain" do
      stub_valid_oauth_hash

      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:eve_online_sso]
      request.env["omniauth.origin"] = "//google.com"

      get :create, params: {provider: "eve_online_sso"}

      should redirect_to(calendar_url)
    end

    it "schedules upcoming events pull, when character is new" do
      stub_valid_oauth_hash(build(:character))

      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:eve_online_sso]
      request.env["omniauth.origin"] = nil

      expect { get(:create, params: {provider: "eve_online_sso"}) }
        .to have_enqueued_job(PullUpcomingEventsJob)
    end

    it "does not schedule upcoming events pull, when character exists" do
      stub_valid_oauth_hash(create(:character, created_at: 1.hour.ago))

      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:eve_online_sso]
      request.env["omniauth.origin"] = nil

      expect { get(:create, params: {provider: "eve_online_sso"}) }
        .not_to have_enqueued_job(PullUpcomingEventsJob)
    end
  end

  context "#destroy" do
    before { stub_current_character }

    it "resets the current session" do
      expect(controller).to receive(:reset_session)

      get(:destroy)
    end

    it "logs the current character out" do
      get(:destroy)

      expect(analytics).to have_tracked("Logged out")
    end
  end
end
