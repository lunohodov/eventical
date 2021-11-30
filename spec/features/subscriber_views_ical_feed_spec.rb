require "rails_helper"

feature "subscriber views iCal feed", type: :feature do
  scenario "and sees incoming events" do
    character = create(:character)
    access_token = create(:access_token, :personal, issuer: character)
    create(:event, character: character)
    create(:event, character: character)

    visit_calendar_feed_path(access_token)

    expect(page).to have_ical_content
  end

  scenario "and preferred time zone is not used" do
    character = create(:character, time_zone: "Europe/Sofia")
    access_token = create(:access_token, :personal, issuer: character)
    create(:event, character: character)
    create(:event, character: character)

    visit_calendar_feed_path(access_token)

    expect(page).not_to have_content "Europe/Sofia"
    expect(page).to have_content "Etc/UTC"
  end

  scenario "and sees empty feed, when there are no upcoming events" do
    character = create(:character)
    access_token = create(:access_token, :personal, issuer: character)

    visit_calendar_feed_path(access_token)

    expect(page).to have_ical_content
  end

  def visit_calendar_feed_path(access_token, time_zone: nil)
    visit calendar_feed_path(
      id: access_token.token,
      params: {tz: time_zone&.name, format: :ics}
    )
  end

  scenario "and sees public events, when feed is public" do
    character = create(:character)
    access_token = create(:access_token, :public, issuer: character)
    create(:event, :public, character: character)
    create(:event, :public, character: character)

    visit_calendar_feed_path(access_token)

    expect(page).to have_ical_content
  end

  matcher :have_ical_content do
    match do |actual|
      expect(actual).to have_content("BEGIN:VCALENDAR")
      expect(actual).to have_content("END:VCALENDAR")
    end
  end
end
