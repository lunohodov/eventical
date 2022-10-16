class SecretCalendarsController < ApplicationController
  include Onboarding

  before_action :authenticate
  before_action :ensure_onboarding_complete, only: :show

  def show
    @secret_token = access_token
    @time_zone = current_character.time_zone
  end

  def create
    AccessToken.transaction do
      AccessToken.revoke!(access_token) if access_token

      AccessToken.create!(character: current_character)

      analytics.track_access_token_revoked(access_token) if access_token
    end

    redirect_to secret_calendar_path
  end

  private

  def access_token
    @access_token ||= AccessToken.for(current_character)
  end
end
