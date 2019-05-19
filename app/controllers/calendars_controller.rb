class CalendarsController < ApplicationController
  before_action :authenticate

  def show
    @personal_token = require_personal_token
    @time_zone = character_settings.time_zone
  end

  def create
    # This should be OK for now. Consider a dedicated controller
    # for settings updates when we have more settings
    case params[:commit]
    when /time zone/i
      remember_preferred_time_zone(params[:tz])
    else
      personal_token.try(&:revoke!)
    end

    redirect_to calendar_url
  end

  private

  def remember_preferred_time_zone(value)
    character_settings.update!(time_zone: value)
  end

  def personal_token
    AccessToken.personal(current_character).current.last
  end

  def require_personal_token
    token = personal_token

    # A character always has a secret address. Generate new, if the
    # old one is expired
    if token.nil?
      token = AccessToken.create_personal!(current_character)
    end

    token
  end
end
