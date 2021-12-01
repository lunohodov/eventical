class SettingsController < ApplicationController
  before_action :authenticate

  def update
    current_character.update!(settings_params)

    redirect_back(fallback_location: private_access_path)
  end

  private

  def settings_params
    params.permit(:time_zone)
  end
end
