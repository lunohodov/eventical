class Analytics
  ACCOUNTS_CATEGORY = "Accounts".freeze

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
    grantee = access_token.grantee
    event_action = if access_token.revoked?
                     "Revoked access token used (#{consumer})"
                   elsif access_token.expired?
                     "Expired access token used (#{consumer})"
                   else
                     "Access token used (#{consumer})"
                   end

    track(
      event_action,
      category: "Calendars",
      label: grantee.name,
      user_id: grantee.id,
    )
  end

  def track_upcoming_events_pulled
    track(
      "Upcoming events pulled",
      category: "Background jobs",
      label: character.name,
      non_interactive: true,
    )
  end

  private

  attr_reader :character

  def track(event, properties = {})
    backend.event(
      action: event,
      user_id: character.id,
      **default_event_properties.merge(properties),
    )
  end

  def default_event_properties
    {
      anonymize_ip: true,
      category: "All",
      data_source: "server",
    }
  end

  ActiveSupport.run_load_hooks(:analytics, self)
end
