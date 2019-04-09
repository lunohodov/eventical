class EventSynchronization
  attr_reader :character
  attr_reader :source

  def initialize(character:, source: nil)
    @character = character
    @source = source || Eve::Esi.character_calendar(character)
  end

  def call
    event_data = fetch_event_data

    Event.transaction do
      event_data.map(&method(:sync_event))
    end
  end

  private

  def fetch_event_data
    source.events
  end

  def sync_event(data)
    event = Event.find_or_initialize_by(character: character, uid: data.uid)

    event.importance = data.importance
    event.response = data.response
    event.starts_at = data.starts_at
    event.title = data.title

    event.save!
  end
end