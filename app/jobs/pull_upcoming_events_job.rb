# frozen_string_literal: true

require "ostruct"

class PullUpcomingEventsJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound
  discard_on EveOnline::Exceptions::Forbidden
  discard_on EveOnline::Exceptions::Unauthorized
  # Wait for next schedule (see `scheduler.rake`)
  discard_on EveOnline::Exceptions::ServiceUnavailable
  discard_on OAuth2::Error

  def perform(character_id)
    @character_id = character_id

    ensure_valid_access_token

    remote_events = fetch_remote_events

    Event.transaction do
      # Delete obsolete events
      keep_uids = remote_events.map(&:uid)
      Event.upcoming_for(character, since: Time.current).
        where.not(uid: keep_uids).
        delete_all
      # Save new or update existing
      remote_events.map { |e| Event.synchronize(e) }
    end
  end

  private

  attr_reader :character_id

  def fetch_remote_events
    character_calendar.events.map do |event|
      OpenStruct.new(
        character: character,
        uid: event.event_id,
        response: event.event_response,
        title: event.title,
        starts_at: event.event_date,
      ).freeze
    end
  end

  def ensure_valid_access_token
    Eve::RenewAccessToken.new(character, force: false).call
  end

  def character_calendar
    EveOnline::ESI::CharacterCalendar.new(
      token: character.token,
      character_id: character.uid,
    )
  end

  def character
    @character ||= Character.find(character_id)
  end
end
