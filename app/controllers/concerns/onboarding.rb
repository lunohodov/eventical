# frozen_string_literal: true

module Onboarding
  extend ActiveSupport::Concern

  def ensure_onboarding_complete
    redirect_to onboarding_path unless onboarding_complete?
  end

  def onboarding_complete?
    AccessToken.private.where(issuer: current_character).current.exists?
  end
end
