Raven.configure do |config|
  # Set by bin/deploy
  config.release = ENV.fetch("HEROKU_SLUG_COMMIT", "unknown").split(" ").first

  config.async = lambda { |event|
    SentryJob.perform_later(event)
  }

  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]
end
