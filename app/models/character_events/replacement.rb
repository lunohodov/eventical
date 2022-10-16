class CharacterEvents::Replacement
  def initialize(character, events)
    @character = character
    @upcoming_events = events.select { |e| e.character == character }
  end

  def call
    Event.transaction do
      replace_events
      yield if block_given?
    end
  end

  private

  attr_reader :character
  attr_reader :upcoming_events

  def replace_events
    removed_events.destroy_all

    upcoming_events.map do |event|
      Event.synchronize(event)
    end
  end

  def removed_events
    uids_to_keep = upcoming_events.map(&:uid)

    Event
      .where("starts_at >= ?", Time.current)
      .where(character: character)
      .where.not(uid: uids_to_keep)
  end
end
