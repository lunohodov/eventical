class AddCharacterToSentryContext
  def initialize(app)
    @app = app
  end

  def call(env)
    session = ActionDispatch::Request.new(env).session

    if session[:character_id].present?
      Raven.user_context(character_id: session[:character_id])
    end

    @app.call(env)
  end
end
