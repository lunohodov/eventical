class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_character
  helper_method :signed_in?

  protected

  def authorize
    redirect_to login_url unless signed_in?
  end

  def current_character
    @current_character ||= if session[:character_id]
                             Character.find(session[:character_id])
                           end
  end

  def signed_in?
    current_character.present?
  end
end
