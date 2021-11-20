require "eventical/middleware/add_character_to_sentry_context"

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger]
  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]
  config.release = "eventical@#{Eventical.release_version}"
  config.traces_sample_rate = 0.25
end

module Eventical
  class Application < Rails::Application
    config.middleware.use(Middleware::AddCharacterToSentryContext, Sentry)
  end
end
