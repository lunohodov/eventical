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
      Rails.logger.info "Skip event sync for character with voided token (id = #{c.id})."
    end

    entitled_characters.each_with_index do |c, index|
      delay = (index * 15).seconds
      PullEventsJob.set(wait: delay).perform_later(c.id)
    end
  end
end
