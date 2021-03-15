class Analytics
  ACCOUNTS_CATEGORY = "Accounts".freeze
  BACKGROUND_JOBS_CATEGORY = "Background jobs".freeze

  class_attribute :backend

  def initialize(character, backend: self.backend)
    @backend = backend
    @character = character
  end

  def track_account_created
    track("Account created", category: ACCOUNTS_CATEGORY, label: character.name)
  end

  def track_access_token_revoked
    track("Access token revoked", category: "Calendars", label: character.name)
  end

  def track_refresh_token_voided
    track("Refresh token voided", category: "ESI", label: character.name)
  end

  def track_character_logged_in
    track("Logged in", category: ACCOUNTS_CATEGORY, label: character.name)
  end

  def track_character_logged_out
    track("Logged out", category: ACCOUNTS_CATEGORY, label: character.name)
  end

  def track_access_token_used(access_token, consumer: nil)
    action =
      if access_token.revoked?
        "Revoked access token used (#{consumer})"
      elsif access_token.expired?
        "Expired access token used (#{consumer})"
      else
        "Access token used (#{consumer})"
      end

    if access_token.public?
      char = access_token.issuer
      action = "Public access token used (#{consumer})"
      track(action, category: "Calendars", label: char.name, user_id: nil)
    else
      char = access_token.grantee
      track(action, category: "Calendars", label: char.name, user_id: char.id)
    end
  end

  def track_upcoming_events_pulled
    track(
      "Upcoming events pulled",
      category: BACKGROUND_JOBS_CATEGORY,
      label: character.name,
      non_interactive: true
    )
  end

  def track_event_details_pulled
    track(
      "Event details pulled",
      category: BACKGROUND_JOBS_CATEGORY,
      label: character.name,
      non_interactive: true
    )
  end

  private

  attr_reader :character

  def track(event, properties = {})
    backend.event(
      action: event,
      user_id: character.id,
      **default_event_properties.merge(properties)
    )
  end

  def default_event_properties
    {
      anonymize_ip: true,
      category: "All",
      data_source: "server"
    }
  end

  ActiveSupport.run_load_hooks(:analytics, self)
end
