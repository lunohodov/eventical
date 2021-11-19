# frozen_string_literal: true

class PullEventDetailsJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    @event_id = event_id

    character.ensure_token_not_expired!

    Sentry.set_user(id: character.id, username: character.name)

    event.update!(
      details_updated_at: Time.current,
      importance: character_calendar_event.importance,
      owner_category: character_calendar_event.owner_type,
      owner_name: character_calendar_event.owner_name,
      owner_uid: character_calendar_event.owner_id
    )

    track_event_details_pulled
  rescue EveOnline::Exceptions::ResourceNotFound => e
    # Pass. Log the error to keep an eye on such situations
    report_error(e)
    # Drop the event, it has been deleted
    event.destroy!
  end

  private

  attr_reader :event_id

  def track_event_details_pulled
    analytics.track_event_details_pulled(character)
  end

  def event
    @event ||= Event.includes(:character).find(event_id)
  end

  def character
    @character ||= event.character
  end

  def character_calendar_event
    @character_calendar_event ||=
      EveOnline::ESI::CharacterCalendarEvent.new(
        character_id: character.uid,
        event_id: event.uid,
        token: character.token
      )
  end
end
