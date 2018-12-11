OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :eve_online_sso,
    ENV["EVE_ONLINE_CLIENT_ID"],
    ENV["EVE_ONLINE_SECRET_KEY"],
    scope: "esi-calendar.read_calendar_events.v1"
end
