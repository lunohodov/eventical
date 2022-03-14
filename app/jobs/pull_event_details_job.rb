# frozen_string_literal: true

class PullEventDetailsJob < ApplicationJob
  queue_as :default

  def perform(event_uid)
    characters = Character.active.distinct.joins(:events).where(events: {uid: event_uid})

    updated = false
    characters.each do |character|
      Sentry.set_user(id: character.id, username: character.name)

      # Will pull details as long as `updated` is nil or false
      updated ||= pull_details(character, event_uid)

      analytics.track_event_details_pulled(character)
    end
  end

  private

  def pull_details(character, event_uid)
    character.ensure_token_not_expired!

    esi_event = EveOnline::ESI::CharacterCalendarEvent.new(
      character_id: character.uid,
      event_id: event_uid,
      token: character.token
    )

    update_for_everyone(esi_event)

    true
  rescue EveOnline::Exceptions::ResourceNotFound
    # The event may not be available for this particular character.
    false
  rescue Eve::AccessToken::Error
    # Character may have revoked it's refresh token during the time
    # this job was in the queue.
    false
  end

  def update_for_everyone(esi_event)
    Event
      .where(uid: esi_event.event_id)
      .update_all(
        starts_at: esi_event.date,
        details_updated_at: Time.current,
        importance: esi_event.importance,
        owner_category: esi_event.owner_type,
        owner_name: esi_event.owner_name,
        owner_uid: esi_event.owner_id,
        updated_at: Time.current
      )
  end
end
