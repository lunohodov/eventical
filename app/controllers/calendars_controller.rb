class CalendarsController < ApplicationController
  before_action :authenticate

  def show
    @personal_token = require_personal_token
  end

  private

  def require_personal_token
    token = AccessToken.personal(current_character).current.last

    # A character always has a secret address. Generate new, if the
    # old one is expired
    if token.nil?
      token = AccessToken.create_personal!(current_character)
    end

    token
  end
end
