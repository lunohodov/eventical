require "eventical/middleware/add_character_to_sentry_context"

Sentry.init do |config|
  # Set by Dyno Metadata. See https://devcenter.heroku.com/articles/dyno-metadata
  config.release = ("eventical@" + ENV.fetch("HEROKU_RELEASE_VERSION", "unknown").strip)

  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]
end

module Eventical
  class Application < Rails::Application
    config.middleware.use(Middleware::AddCharacterToSentryContext, Sentry)
  end
end
