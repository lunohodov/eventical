class OnboardingsController < ApplicationController
  include Onboarding

  before_action :authenticate

  def show
    redirect_to secret_token_path if onboarding_complete?
  end
end
