require "rails_helper"

feature "subscriber views upcoming events", type: :feature do
  scenario "events are grouped by date" do
    char = create(:character)
    event_dates = [
      create(:event, character: char, starts_at: Date.current),
      create(:event, character: char, starts_at: Date.tomorrow),
    ].map(&:starts_at)

    visit calendar_feed_path(id: "secret-hash")

    event_dates.each do |date|
      within(event_list_selector(date)) do
        expect(page).to have_css("tr:first", text: date.strftime("%a %d %b"))
        expect(page).to have_css("tr.event", count: 1)
      end
    end
  end

  scenario "and sees event details" do
    char = create(:character)
    event = create(:event, character: char, starts_at: Date.tomorrow)

    visit calendar_feed_path(id: "secret-hash")

    within("tr.event") do
      expect(page).to have_content(event.starts_at.strftime("%H:%M"))
      expect(page).to have_content(event.title)
      expect(page).to have_content(
        event.starts_at.utc.strftime("%Y-%m-%d %H:%M"),
      )
    end
  end

  def event_list_selector(date)
    ".event-list[data-date=\"#{date.strftime('%Y-%m-%d')}\"]"
  end
end
