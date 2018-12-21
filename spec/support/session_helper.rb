require_relative "oauth_support"

module SessionHelper
  include OAuthSupport

  def sign_in
    sign_in_as create(:character)
  end

  def sign_in_as(character)
    @current_character = character

    stub_valid_oauth_hash(@current_character)

    visit auth_eve_online_sso_callback_path(as: @current_character)
  end

  def current_character
    @current_character
  end
end

RSpec.configure do |config|
  config.include SessionHelper, type: :feature
end
