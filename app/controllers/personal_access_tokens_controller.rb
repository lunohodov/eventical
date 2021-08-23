class PersonalAccessTokensController < ApplicationController
  before_action :authenticate

  def create
    token = AccessToken.personal(current_character).current.last

    AccessToken.transaction do
      # There should be only one active private access token.
      # Hence, creating a new token must revoke the old one.
      if token
        AccessToken.revoke!(token)
      end
      AccessToken.personal(current_character).create!
    end

    if token
      analytics.track_access_token_revoked(token)
    end

    redirect_to calendar_path
  end
end
