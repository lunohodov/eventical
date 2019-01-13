require "rails_helper"

feature "subscriber views upcoming events", type: :feature do
  scenario "events are grouped by date" do
    sign_in

    events = [
      create(:event, starts_at: Time.current),
      create(:event, starts_at: 1.day.from_now),
    ]
    stub_calendar(character: current_character, events: events)

    visit_calendar_feed_path

    events.map(&:starts_at).each do |date|
      within(event_list_selector(date)) do
        expect(page).to have_css("tr:first", text: date.strftime("%a %d %b"))
        expect(page).to have_css("tr.event", count: 1)
      end
    end
  end

  scenario "and sees event details" do
    sign_in

    event = create(:event, starts_at: 1.day.from_now)
    stub_calendar(character: current_character, events: [event])

    visit_calendar_feed_path

    within("tr.event") do
      expect(page).to have_content(event.starts_at.strftime("%H:%M"))
      expect(page).to have_content(event.title)
      expect(page).to have_content(
        event.starts_at.utc.strftime("%Y-%m-%d %H:%M"),
      )
    end
  end

  scenario "and sees informative text, when there are no upcoming events" do
    sign_in

    stub_calendar(character: current_character, events: [])

    visit_calendar_feed_path

    expect(page).to have_content("There are no upcoming events")
  end

  def visit_calendar_feed_path
    visit calendar_feed_path(id: create_access_token.token)
  end

  def stub_calendar(character:, events: [])
    allow(CalendarSync).to receive(:new).and_return(proc { true })

    agenda = create(:agenda, events: events)

    double("calendar", agenda: agenda).tap do |calendar|
      allow(Calendar).to receive(:new).
        with(character).
        and_return(calendar)
    end
  end

  def create_access_token
    create(:access_token, :personal, issuer: current_character)
  end

  def event_list_selector(date)
    ".event-list[data-date=\"#{date.strftime('%Y-%m-%d')}\"]"
  end
end
