# frozen_string_literal: true

class PullEventDetailsJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    @event_id = event_id

    ensure_valid_access_token

    event.update!(
      details_updated_at: Time.current,
      importance: character_calendar_event.importance,
      owner_category: character_calendar_event.owner_type,
      owner_name: character_calendar_event.owner_name,
      owner_uid: character_calendar_event.owner_id,
    )
  end

  private

  attr_reader :event_id

  def ensure_valid_access_token
    Eve::RenewAccessToken.new(character, force: false).call
  end

  def event
    @event ||= Event.includes(:character).find(event_id)
  end

  def character
    @character ||= event.character
  end

  def character_calendar_event
    @character_calendar_event ||= begin
      EveOnline::ESI::CharacterCalendarEvent.new(
        character_id: character.uid,
        event_id: event.uid,
        token: character.token,
      )
    end
  end
end
