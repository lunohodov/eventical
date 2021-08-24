class CalendarsController < ApplicationController
  before_action :authenticate

  def show
    @personal_token = AccessToken.personal(current_character).current.last
    @time_zone = character_settings.time_zone

    if @personal_token.present?
      render :show
    else
      render :onboarding
    end
  end
end
