Eve::Esi.configure do |config|
  config.client_id = ENV.fetch("EVE_ONLINE_CLIENT_ID")
  config.client_secret = ENV.fetch("EVE_ONLINE_SECRET_KEY")
end
