# frozen_string_literal: true

require "ostruct"

class PullUpcomingEventsJob < ApplicationJob
  queue_as :default

  retry_on EveOnline::Exceptions::BadGateway, wait: :exponentially_longer, attempts: 5

  def perform(character_id)
    @character_id = character_id

    Sentry.set_user(id: character_id, username: character.name)

    if character.refresh_token_voided?
      Rails.logger.info "Skip event sync for character with voided token (id = #{character.id})."
    else
      character.ensure_token_not_expired!
      sync_events
    end
  end

  private

  attr_reader :character_id

  def sync_events
    remote_events = fetch_remote_events

    track_upcoming_events_pulled

    Event.transaction do
      # Delete obsolete events
      keep_uids = remote_events.map(&:uid)
      Event.upcoming_for(character, since: Time.current)
        .where.not(uid: keep_uids)
        .delete_all
      # Save new or update existing
      remote_events.map { |e| Event.synchronize(e) }
    end
  end

  def track_upcoming_events_pulled
    analytics.track_upcoming_events_pulled(character)
  end

  def fetch_remote_events
    character_calendar.events.map do |event|
      OpenStruct.new(
        character: character,
        uid: event.event_id,
        response: event.event_response,
        title: event.title,
        starts_at: event.event_date
      ).freeze
    end
  end

  def character_calendar
    EveOnline::ESI::CharacterCalendar.new(
      token: character.token,
      character_id: character.uid
    )
  end

  def character
    @character ||= Character.find(character_id)
  end
end
