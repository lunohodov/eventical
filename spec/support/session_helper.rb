require_relative "oauth_support"

module SessionHelper
  include OAuthSupport

  def sign_in
    sign_in_as create(:character)
  end

  def sign_in_as(character)
    @current_character = character

    auth_hash = build(:oauth_hash, uid: character.uid, character_owner_hash: character.owner_hash)
    stub_oauth_hash(auth_hash)

    visit auth_eve_online_sso_callback_path(as: @current_character)
  end

  def current_character
    @current_character
  end
end

RSpec.configure do |config|
  config.include SessionHelper, type: :feature
end
