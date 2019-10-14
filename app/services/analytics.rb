class Analytics
  class_attribute :backend

  def initialize(character, backend: self.backend)
    @backend = backend
    @character = character
  end

  def track_account_created
    track("Account created", category: "Accounts", label: character.name)
  end

  def track_access_token_revoked
    track("Access token revoked", category: "Calendars", label: character.name)
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
end
