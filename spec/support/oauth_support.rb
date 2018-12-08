module OAuthSupport
  def stub_valid_oauth_hash(character = nil)
    OmniAuth.config.mock_auth[:eve_online_sso] = build(
      :oauth_hash,
      character: character || build_stubbed(:character),
    )
  end

  def stub_oauth_failure
    OmniAuth.config.mock_auth[:eve_online_sso] = :invalid_credentials
  end
end

RSpec.configure do |config|
  config.include OAuthSupport, type: :controller
end
