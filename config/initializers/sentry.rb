Raven.configure do |config|
  # Set by bin/deploy
  config.release = ENV.fetch("CURRENT_SHA", "unknown").split(" ").first
end
