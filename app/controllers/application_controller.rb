class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_raven_context

  helper_method :current_character
  helper_method :signed_in?

  protected

  def set_raven_context
    Raven.user_context(id: current_character&.uid)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

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
