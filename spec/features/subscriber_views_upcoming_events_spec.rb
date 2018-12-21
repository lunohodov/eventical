require "rails_helper"

feature "subscriber views upcoming events", type: :feature do
  scenario "events are grouped by date" do
    sign_in

    access_token = create_access_token
    event_dates = [
      create(:event, character: current_character, starts_at: Date.current),
      create(:event, character: current_character, starts_at: Date.tomorrow),
    ].map(&:starts_at)

    visit calendar_feed_path(id: access_token.token)

    event_dates.each do |date|
      within(event_list_selector(date)) do
        expect(page).to have_css("tr:first", text: date.strftime("%a %d %b"))
        expect(page).to have_css("tr.event", count: 1)
      end
    end
  end

  scenario "and sees event details" do
    sign_in

    access_token = create_access_token
    event = create(:event, character: current_character, starts_at: Date.tomorrow)

    visit calendar_feed_path(id: access_token.token)

    within("tr.event") do
      expect(page).to have_content(event.starts_at.strftime("%H:%M"))
      expect(page).to have_content(event.title)
      expect(page).to have_content(
        event.starts_at.utc.strftime("%Y-%m-%d %H:%M"),
      )
    end
  end

  scenario "and sees informative test, when there are no upcoming events" do
    sign_in

    access_token = create_access_token

    visit calendar_feed_path(id: access_token.token)

    expect(page).to have_content("There are no upcoming events")
  end

  def create_access_token
    create(:access_token, :personal, issuer: current_character)
  end

  def event_list_selector(date)
    ".event-list[data-date=\"#{date.strftime('%Y-%m-%d')}\"]"
  end
end
