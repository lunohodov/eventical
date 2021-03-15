namespace :events do
  desc "Remove obsolete events"
  task clean: :environment do
    delete_count = EventCleaner.new.call
    Rails.logger.info "Removed #{delete_count} events."
  end

  desc "Schedule pull of upcoming events from ESI"
  task pull: :environment do
    excluded_characters, entitled_characters =
      Character.all.partition(&:refresh_token_voided?)

    excluded_characters.each do |c|
      Rails.logger.info "Skip pull of events for character (id = #{c.id})."
    end

    entitled_characters.each_with_index do |c, index|
      delay = (5 + index).minutes
      PullUpcomingEventsJob.set(wait: delay).perform_later(c.id)
    end
  end

  desc "Schedule pull of event details for all upcoming events"
  task "details:pull": :environment do
    excluded_characters, entitled_characters =
      Character.all.partition(&:refresh_token_voided?)

    excluded_characters.each do |c|
      Rails.logger.info "Skip events:details:pull for character (id = #{c.id})."
    end

    character_ids = entitled_characters.pluck(:id)

    unless character_ids.empty?
      event_ids =
        Event
          .where(details_updated_at: nil, character_id: character_ids)
          .pluck(:id)

      event_ids.each_with_index do |event_id, index|
        delay = (5 + index).minutes
        PullEventDetailsJob.set(wait: delay).perform_later(event_id)
      end
    end
  end
end
