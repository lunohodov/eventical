class CharacterEvents::Remote
  Entry = Struct.new(
    :character,
    :importance,
    :owner_category,
    :owner_name,
    :owner_uid,
    :response,
    :starts_at,
    :title,
    :uid,
    keyword_init: true
  )

  include Enumerable

  attr_reader :character

  def self.eager(character)
    new(character).tap { |instance| instance.send(:event_entries) }
  end

  def initialize(character)
    @character = character
  end

  def each(&block)
    event_entries.each(&block)
  end

  private

  def character_calendar
    @character_calendar ||= EveOnline::ESI::CharacterCalendar.new(
      token: character.token,
      character_id: character.uid
    )
  end

  def event_entries
    @event_entries ||= load_events
  end

  def load_events
    character.ensure_token_not_expired!

    character_calendar.events.map do |event|
      Entry.new(
        character: character,
        uid: event.event_id,
        response: event.event_response,
        title: event.title,
        starts_at: event.event_date
      ).freeze
    end
  end
end
