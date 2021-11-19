require "eventical/middleware/add_character_to_sentry_context"

Sentry.init do |config|
  config.release = "eventical@#{Eventical.release_version}"

  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]
end

module Eventical
  class Application < Rails::Application
    config.middleware.use(Middleware::AddCharacterToSentryContext, Sentry)
  end
end
