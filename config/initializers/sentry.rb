Raven.configure do |config|
  # Set by bin/deploy
  config.release = ENV.fetch("CURRENT_SHA", "unknown").split(" ").first

  config.async = lambda { |event|
    SentryJob.perform_later(event)
  }

  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]
end
