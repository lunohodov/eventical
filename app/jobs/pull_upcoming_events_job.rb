# frozen_string_literal: true

require "ostruct"

class PullUpcomingEventsJob < ApplicationJob
  queue_as :default

  def perform(character_id)
    @character_id = character_id

    ensure_valid_access_token

    fetch_events.map { |e| Event.synchronize(e) }
  rescue ActiveRecord::RecordInvalid,
         EveOnline::Exceptions::Forbidden,
         EveOnline::Exceptions::ServiceUnavailable,
         EveOnline::Exceptions::Unauthorized,
         OAuth2::Error,
         StandardError => e
    report_error(e)
  end

  private

  attr_reader :character_id

  def fetch_events
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
