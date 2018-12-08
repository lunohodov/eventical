require "rails_helper"

describe SessionsController, type: :controller do
  before { stub_valid_oauth_hash }

  context "#create" do
    it "redirects to auth origin" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:eve_online_sso]
      request.env["omniauth.origin"] = "/about"

      get :create, params: { provider: "eve_online_sso" }

      should redirect_to("/about")
    end

    it "redirects to calendar path without an auth origin" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:eve_online_sso]
      request.env["omniauth.origin"] = nil

      get :create, params: { provider: "eve_online_sso" }

      should redirect_to(calendar_url)
    end

    xit "does not redirect to an outside domain" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:eve_online_sso]
      request.env["omniauth.origin"] = "//google.com"

      get :create, params: { provider: "eve_online_sso" }

      should redirect_to(calendar_url)
    end
  end
end
