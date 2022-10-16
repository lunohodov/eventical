class EventCleaner
  delegate :logger, to: Rails

  def call
    Event.transaction do
      [
        clean_aged,
        clean_for_voided_characters
      ].sum
    end
  end

  private

  def clean_aged
    started_at = 1.month.ago
    logger.info "Removing events which took place before #{started_at}"
    Event.delete_by("starts_at < ?", started_at)
  end

  def clean_for_voided_characters
    logger.info "Removing events belonging to voided characters"
    Event.delete_by(character: Character.voided)
  end
end
