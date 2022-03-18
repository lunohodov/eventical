OmniAuth.config.logger = Rails.logger

# Using a setup phase allows for ESI's credentials constants
# to be defined at any time during app's initialization
setup_proc = lambda do |env|
  env["omniauth.strategy"].options[:client_id] = EVE_ONLINE_CLIENT_ID
  env["omniauth.strategy"].options[:client_secret] = EVE_ONLINE_SECRET_KEY
  env["omniauth.strategy"].options[:scope] = "esi-calendar.read_calendar_events.v1"
  # rubocop:enable Layout/LineLength
end

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.allowed_request_methods = [:post]

  provider :developer unless Rails.env.production?
  provider :eve_online_sso, setup: setup_proc
end
