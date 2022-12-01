class ApplicationController < ActionController::Base
  include Authenticating

  protect_from_forgery

  before_action :set_sentry_context
  before_action :set_current_request_details

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

  def set_current_request_details
    Current.ip_address = request.ip
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
  end
end
