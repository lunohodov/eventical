# frozen_string_literal: true

module Onboarding
  extend ActiveSupport::Concern

  def onboarding_complete?
    AccessToken.private.where(issuer: current_character).current.exists?
  end
end
