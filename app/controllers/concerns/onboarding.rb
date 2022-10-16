# frozen_string_literal: true

module Onboarding
  extend ActiveSupport::Concern

  def ensure_onboarding_complete
    redirect_to onboarding_path unless onboarding_complete?
  end

  def onboarding_complete?
    AccessToken.for(current_character).present?
  end
end
