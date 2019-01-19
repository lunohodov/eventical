require "rails_helper"

feature "subscriber views iCalendar feed", type: :feature do
  ICAL_DATETIME_FORMAT = "%Y%m%dT%H%M%S".freeze

  before do
    # Stub calendar synchronization so no requests to ESI are made
    allow(EventSynchronization).to receive(:new).and_return(proc { true })
  end

  scenario "and sees incoming events" do
    character = create(:character)
    access_token = create(:access_token, :personal, issuer: character)
    time_zone = ActiveSupport::TimeZone["Europe/Amsterdam"]

    create(:event, character: character)
    create(:event, character: character)

    visit_calendar_feed_path(access_token, time_zone: time_zone)

    expect(page).to have_content("")
  end

  def visit_calendar_feed_path(access_token, time_zone: nil)
    visit calendar_feed_path(
      id: access_token.token,
      params: { tz: time_zone&.name, format: :ics },
    )
  end
end
