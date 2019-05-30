OmniAuth.config.logger = Rails.logger

# Use a setup phase so that client credentials are set
# after the app is initialized i.e Eve::Esi is configured
SETUP_PROC = lambda do |env|
  # rubocop:disable Metrics/LineLength
  env["omniauth.strategy"].options[:client_id] = Eve::Esi.config.client_id
  env["omniauth.strategy"].options[:client_secret] = Eve::Esi.config.client_secret
  env["omniauth.strategy"].options[:scope] = "esi-calendar.read_calendar_events.v1"
  # rubocop:enable Metrics/LineLength
end

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.allowed_request_methods = [:post]
  OmniAuth.config.before_request_phase =
    RequestForgeryProtectionTokenVerification.new

  provider :developer unless Rails.env.production?
  provider :eve_online_sso, setup: SETUP_PROC
end
