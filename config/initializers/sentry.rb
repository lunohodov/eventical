require "eventical/middleware/add_character_to_sentry_context.rb"

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
    config.middleware.use(Middleware::AddCharacterToSentryContext, Raven)
  end
end
