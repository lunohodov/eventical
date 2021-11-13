class PersonalAccessTokensController < ApplicationController
  before_action :authenticate

  def create
    token = AccessToken.private.where(issuer: current_character).current.last

    AccessToken.transaction do
      # There should be only one active private access token.
      # Hence, creating a new token must revoke the old one.
      if token
        AccessToken.revoke!(token)
      end
      AccessToken.create!(issuer: current_character, grantee: current_character)
    end

    if token
      analytics.track_access_token_revoked(token)
    end

    redirect_to calendar_path
  end
end
