module Eventical
  module Middleware
    class AddCharacterToSentryContext
      def initialize(app, backend)
        @app = app
        @sentry_backend = backend
      end

      def call(env)
        session = ActionDispatch::Request.new(env).session

        if session[:character_id].present?
          @sentry_backend.user_context(character_id: session[:character_id])
        end

        @app.call(env)
      end
    end
  end
end
