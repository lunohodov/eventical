# frozen_string_literal: true

class PullEventsJob < ApplicationJob
  queue_as :default

  # FIXME: Don't let EveOnline errors bubble up
  retry_on EveOnline::Exceptions::BadGateway, wait: :exponentially_longer, attempts: 5
  retry_on EveOnline::Exceptions::ServiceUnavailable, wait: :exponentially_longer, attempts: 5

  def perform(character_id)
    character = Character.find(character_id)

    Sentry.set_user(id: character.id, username: character.name)

    if !character.refresh_token_voided?
      CharacterEvents.new(character).pull
      analytics.track_upcoming_events_pulled(character)
    else
      logger.info "Skip event sync for character with voided token (id = #{character.id})."
    end
  end
end
