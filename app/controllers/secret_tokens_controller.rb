class SecretTokensController < ApplicationController
  include Onboarding

  before_action :authenticate
  before_action :ensure_onboarding_complete, only: :show

  def show
    @secret_token = access_token
    @time_zone = character_settings.time_zone
  end

  def create
    AccessToken.transaction do
      AccessToken.revoke!(access_token) if access_token

      AccessToken.create!(issuer: current_character, grantee: current_character)

      analytics.track_access_token_revoked(access_token) if access_token
    end

    redirect_to secret_token_path
  end

  private

  def access_token
    @access_token ||= AccessToken.private.where(issuer: current_character).current.last
  end
end
