require "rails_helper"

feature "Subscriber views public iCal feed", type: :feature do
  scenario "and sees upcoming events" do
    character = create(:character)
    access_token = create(:access_token, :public, issuer: character)
    event = create(:event, :public, character: character)

    visit public_feeds_url(id: access_token.token, format: :ics)

    expect(page).to have_content("BEGIN:VCALENDAR")
    expect(page).to have_content("SUMMARY:#{event.title}")
  end

  scenario "and can not override the preferred time zone" do
    character = create(:character)
    access_token = create(:access_token, :public, issuer: character)
    create(:event, character: character)
    create(:event, character: character)

    visit public_feeds_url(id: access_token.token, params: {tz: "Europe/Sofia"}, format: :ics)

    expect(page).not_to have_content "Europe/Sofia"
    expect(page).to have_content "Etc/UTC"
  end

  scenario "and sees no events, when there are none" do
    character = create(:character)
    access_token = create(:access_token, :public, issuer: character)

    visit public_feeds_url(id: access_token.token, format: :ics)

    expect(page).not_to have_content("BEGIN:VEVENT")
  end
end
