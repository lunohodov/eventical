class OnboardingsController < ApplicationController
  include Onboarding

  before_action :authenticate

  def show
    redirect_to calendar_path if onboarding_complete?
  end
end
