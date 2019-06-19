# frozen_string_literal: true

module Eve
  class EventSource < SimpleDelegator
    def events
      super.map(&method(:map_event))
    end

    private

    def map_event(event)
      OpenStruct.new(
        uid: event.event_id,
        response: event.event_response,
        title: event.title,
        starts_at: event.event_date,
      ).freeze
    end
  end

  module ClassMethods
    def time_zone
      ActiveSupport::TimeZone["UTC"]
    end

    def character_calendar(character)
      calendar = EveOnline::ESI::CharacterCalendar.new(
        token: character.token,
        character_id: character.uid,
      )
      EventSource.new(calendar)
    end
  end

  extend ClassMethods
end
