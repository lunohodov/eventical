namespace :events do
  desc "Remove obsolete events"
  task clean: :environment do
    delete_count = EventCleaner.new.call
    Rails.logger.info "Removed #{delete_count} events."
  end
end
