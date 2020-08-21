class EventCleaner
  attr_reader :max_event_age

  def self.call
    new(max_event_age: 6.months).call
  end

  def initialize(max_event_age:)
    @max_event_age = max_event_age
  end

  def call
    Event.transaction do
      [
        clean_aged,
        clean_belonging_to_deactivated_characters,
      ].sum
    end
  end

  private

  def clean_aged
    Event.delete_by("created_at < ?", max_event_age.ago)
  end

  def clean_belonging_to_deactivated_characters
    Event.delete_by(character: Character.deactivated)
  end
end
