require "rails_helper"

feature "user views calendar", type: :feature do
  scenario "and sees it's private address" do
    sign_in

    visit calendar_path

    expect(page).to have_field("calendar-private-uri", with: /\.ical$/)
  end

  scenario "and sees a button to reset the private address" do
    sign_in

    visit calendar_path

    expect(page).to have_button("Reset secret address")
  end
end
