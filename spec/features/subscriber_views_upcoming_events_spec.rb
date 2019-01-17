require "rails_helper"

feature "subscriber views upcoming events", type: :feature do
  before do
    # Stub calendar synchronization so no requests to ESI are made
    allow(EventSynchronization).to receive(:new).and_return(proc { true })
  end

  scenario "events are grouped by date" do
    sign_in

    events = [
      create(:event, character: current_character, starts_at: Time.current),
      create(:event, character: current_character, starts_at: 1.day.from_now),
    ]

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

    event = create(
      :event,
      character: current_character,
      starts_at: 1.day.from_now,
    )

    visit_calendar_feed_path

    within("tr.event") do
      expect(page).to have_content(event.starts_at.strftime("%H:%M"))
      expect(page).to have_content(event.title)
      expect(page).to have_content(
        event.starts_at.utc.strftime("%Y-%m-%d %H:%M"),
      )
    end
  end

  scenario "and can change preferred time zone" do
    sign_in

    create_list(:event, 2, character: current_character)

    visit_calendar_feed_path(tz: "Sofia")

    select("London", from: :tz)
    click_on("Change")

    expect(page).to have_select(:tz, selected: "(GMT+00:00) London")
  end

  scenario "and sees time in preferred time zone" do
    sign_in

    event = create(
      :event,
      character: current_character,
      starts_at: 1.month.from_now,
    )

    visit_calendar_feed_path(tz: "Sofia")

    within("tr.event") do
      expect(page).to have_content(
        event.starts_at.in_time_zone("Sofia").strftime("%H:%M"),
      )
    end
  end

  scenario "and sees informative text, when there are no upcoming events" do
    sign_in

    visit_calendar_feed_path

    expect(page).to have_content("There are no upcoming events")
  end

  def visit_calendar_feed_path(**params)
    visit calendar_feed_path(id: create_access_token.token, params: params)
  end

  def create_access_token
    create(:access_token, :personal, issuer: current_character)
  end

  def event_list_selector(date)
    ".event-list[data-date=\"#{date.strftime('%Y-%m-%d')}\"]"
  end
end
