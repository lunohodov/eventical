module Authenticating
  extend ActiveSupport::Concern

  included do
    helper_method :current_character
    helper_method :signed_in?
  end

  protected

  def authenticate
    redirect_to root_url unless signed_in?
  end

  def current_character
    @current_character ||=
      if session[:character_id]
        Character.find_by(id: session[:character_id])
      end
  end

  def signed_in?
    current_character.present?
  end
end
