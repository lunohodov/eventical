Raven.configure do |config|
  # Set by Dyno Metadata. See https://devcenter.heroku.com/articles/dyno-metadata
  config.release = ENV.fetch("HEROKU_SLUG_COMMIT", "unknown").split(" ").first

  config.async = lambda { |event|
    SentryJob.perform_later(event)
  }

  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]
end

module Eventical
  class Application < Rails::Application
    config.middleware.use ::AddCharacterToSentryContext
  end
end
