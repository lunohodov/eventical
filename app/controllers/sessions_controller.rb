class SessionsController < ApplicationController
  NEW_SIGNUP_THRESHOLD = 5.seconds.freeze

  def create
    reset_session

    auth_hash = request.env["omniauth.auth"]

    character = SignIn.new(auth_hash).save!

    # Pull upcoming events as soon as possible to improve
    # new-user experience.
    if new_signup?(character)
      pull_upcoming_events(character)
    end

    analytics.track_character_logged_in(character)

    session[:character_id] = character.id

    redirect_to secret_calendar_url
  end

  def destroy
    if signed_in?
      analytics.track_character_logged_out(current_character)
    end

    reset_session

    redirect_to root_url
  end

  private

  def new_signup?(character)
    character.created_at > NEW_SIGNUP_THRESHOLD.ago
  end

  def pull_upcoming_events(character)
    PullEventsJob.perform_later(character.id)
  end
end
