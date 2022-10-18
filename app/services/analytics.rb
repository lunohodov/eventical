class Analytics
  class Backend
    def count(*)
      raise NotImplementedError
    end
  end

  class_attribute :backend

  delegate :count, to: :@backend

  def initialize(backend: self.backend)
    @backend = backend
  end

  def track_access_token_revoked(access_token)
    count("access_token.revoked", resource: access_token.character)
  end

  def track_refresh_token_voided(character)
    count("esi.refresh_token.revoked", resource: character)
  end

  def track_character_logged_in(character)
    count("character.logged_in", resource: character)
  end

  def track_character_logged_out(character)
    count("character.logged_out", resource: character)
  end

  def track_access_token_used(access_token)
    kind =
      if access_token.revoked?
        ".revoked"
      else
        ""
      end

    count("access_token#{kind}.used", resource: access_token)
  end

  def track_upcoming_events_pulled(character)
    count("events.pulled", resource: character)
  end

  ActiveSupport.run_load_hooks(:analytics, self)
end
