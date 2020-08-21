class EventCleaner
  attr_reader :max_event_age
  attr_reader :character_deactivation_threshold

  def self.call
    new.call
  end

  def initialize
    @max_event_age = 6.months
    @character_deactivation_threshold = 2.months
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
    Event.delete_by(character: deactivated_characters)
  end

  def deactivated_characters
    Character.where(["refresh_token_voided_at < ?", character_deactivation_threshold.ago])
  end
end
