class CalendarsController < ApplicationController
  include Onboarding

  before_action :authenticate

  def show
    if onboarding_complete?
      @personal_token = AccessToken.private.where(issuer: current_character).current.last
      @time_zone = character_settings.time_zone
    else
      redirect_to onboarding_path
    end
  end
end
