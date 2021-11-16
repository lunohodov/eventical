module OAuthSupport
  def stub_oauth_hash(auth_hash = nil)
    auth_hash ||= build(:oauth_hash)
    OmniAuth.config.mock_auth[:eve_online_sso] = auth_hash
  end

  def stub_oauth_failure
    OmniAuth.config.mock_auth[:eve_online_sso] = :invalid_credentials
  end
end

RSpec.configure do |config|
  config.include OAuthSupport, type: :controller
end
