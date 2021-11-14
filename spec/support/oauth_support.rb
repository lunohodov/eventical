module OAuthSupport
  def stub_valid_oauth_hash(character = nil)
    OmniAuth.config.mock_auth[:eve_online_sso] =
      oauth_hash_for_character(character || FactoryBot.build_stubbed(:character))
  end

  def oauth_hash_for_character(character)
    FactoryBot.build(
      :oauth_hash,
      uid: character.uid,
      character_name: character.name,
      character_owner_hash: character.owner_hash,
      character_token_type: character.token_type,
      refresh_token: character.refresh_token,
      token: character.token,
      token_expires_at: character.token_expires_at
    )
  end

  def stub_oauth_failure
    OmniAuth.config.mock_auth[:eve_online_sso] = :invalid_credentials
  end
end

RSpec.configure do |config|
  config.include OAuthSupport, type: :controller
end
