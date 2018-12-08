OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.before(:each) do
    OmniAuth.config.mock_auth[:eve_online_sso] = nil
  end
end
