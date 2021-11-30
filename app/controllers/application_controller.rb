class ApplicationController < ActionController::Base
  include Authenticating

  protect_from_forgery

  before_action :set_sentry_context

  protected

  def analytics
    Analytics.new
  end

  def set_sentry_context
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)

    if signed_in?
      Sentry.set_user(id: current_character.id, username: current_character.name)
    end
  end
end
