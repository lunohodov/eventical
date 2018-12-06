class CalendarsController < ApplicationController
  def show
    @character = require_character
  end

  private

  def require_character
    Character.find(params[:character_id])
  end
end
