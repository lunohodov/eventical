require "rails_helper"

feature "user views calendar", type: :feature do
  scenario "and sees it's private address" do
    owner = create(:character)

    visit character_calendar_path(owner)

    expect(page).to have_field('calendar-private-uri', type: :text, with: /basic\.ical/)
  end

  scenario "and sees a button to reset the private address" do
    owner = create(:character)

    visit character_calendar_path(owner)

    expect(page).to have_button('Reset secret address')
  end
end
