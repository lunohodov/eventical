class ApplicationController < ActionController::Base
  helper_method :signed_in?

  protected

  def signed_in?
    params[:logged].presence
  end
end
