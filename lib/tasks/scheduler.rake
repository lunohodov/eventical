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
    character_ids = Character.with_active_refresh_token.pluck(:id)

    event_ids = Event.
      where(details_updated_at: nil, character_id: character_ids).
      pluck(:id)

    event_ids.each_with_index do |event_id, index|
      delay = (5 + index).minutes

      PullEventDetailsJob.
        set(wait: delay).
        perform_later(event_id)
    end
  end
end
