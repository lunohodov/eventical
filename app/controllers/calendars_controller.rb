class CalendarsController < ApplicationController
  before_action :authenticate

  def show
    @personal_token = require_personal_token
  end

  def create
    personal_token.try(&:revoke!)
    redirect_to calendar_url
  end

  private

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
