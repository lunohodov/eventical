namespace :scheduler do
  task pull: "environment" do
    Character.all.each_with_index do |character, index|
      delay = (5 + index).minutes
      PullUpcomingEventsJob.
        set(wait: delay).
        perform_later(character.id)
    end
  end
end
