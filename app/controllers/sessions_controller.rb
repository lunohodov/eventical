class SessionsController < ApplicationController
  NEW_SIGNUP_THRESHOLD = 5.seconds.freeze

  def create
    reset_session

    auth_hash = request.env["omniauth.auth"]

    character = Eve::SignIn.new(auth_hash).call

    if character.present?
      schedule_upcoming_events_pull_if_needed(character)

      analytics.track_character_logged_in(character)

      session[:character_id] = character.id

      redirect_to calendar_url
    else
      redirect_to login_url
    end
  end

  def destroy
    if signed_in?
      analytics.track_character_logged_out(current_character)
    end

    reset_session

    redirect_to root_url
  end

  private

  def schedule_upcoming_events_pull_if_needed(character)
    # Characters signing for the first time may see their upcoming events
    # with a significant delay as we use a scheduled job to pull the
    # events from ESI.
    #
    # Pull upcoming events as soon as possible to improve new-user experience.
    if character.created_at > NEW_SIGNUP_THRESHOLD.ago
      PullUpcomingEventsJob.set(wait: 3.seconds).perform_later(character.id)
    end
  end
end
