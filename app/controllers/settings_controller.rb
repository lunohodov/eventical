class SettingsController < ApplicationController
  before_action :authenticate

  def update
    character_settings.update!(settings_params)

    redirect_back(fallback_location: secret_token_path)
  end

  private

  def settings_params
    params.permit(:time_zone)
  end
end
