namespace :scheduler do
  task pull: "events:pull"

  desc "Schedule pull of upcoming events from ESI"
  task "events:pull": :environment do
    Character.with_active_refresh_token.each_with_index do |character, index|
      delay = (5 + index).minutes
      PullUpcomingEventsJob.
        set(wait: delay).
        perform_later(character.id)
    end
  end

  desc "Schedule pull of event details for all upcoming events"
  task "events:details:pull": :environment do
    Event.where(details_updated_at: nil).each_with_index do |event, index|
      delay = 5.minutes + index.seconds
      PullEventDetailsJob.set(wait: delay).perform_later(event.id)
    end
  end
end
