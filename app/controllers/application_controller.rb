class ApplicationController < ActionController::Base
  include Authenticating

  protect_from_forgery

  before_action :set_sentry_context

  protected

  def analytics
    analytics_for(current_character)
  end

  def analytics_for(character)
    Analytics.new(character)
  end

  def character_settings
    Setting.for_character(current_character)
  end

  def set_sentry_context
    Sentry.set_user(id: current_character&.uid)
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end
end
