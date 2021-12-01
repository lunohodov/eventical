class OnboardingsController < ApplicationController
  include Onboarding

  before_action :authenticate

  def show
    redirect_to private_access_path if onboarding_complete?
  end
end
