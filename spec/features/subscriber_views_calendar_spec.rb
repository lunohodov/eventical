require "rails_helper"

feature "user views calendar", type: :feature do
  scenario "and sees it's private address" do
    sign_in

    access_token = create(:access_token, :personal, issuer: current_character)

    visit calendar_path

    within "#secret-address" do
      expect(page).to have_link(href: /#{access_token.token}$/)
    end
  end

  scenario "and sees it's private address in iCal format" do
    sign_in

    access_token = create(:access_token, :personal, issuer: current_character)

    visit calendar_path

    within "#secret-address-ical" do
      expect(page).to have_link(href: /#{access_token.token}\.ics$/)
    end
  end

  scenario "and sees a button to reset the private address" do
    sign_in

    create(:access_token, :personal, issuer: current_character)

    visit calendar_path

    expect(page).to have_button("Reset secret address")
  end

  scenario "and can change preferred time zone" do
    sign_in

    visit calendar_path

    select("London", from: :tz)
    click_on("Update time zone")

    expect(page).to have_select(:tz, selected: "(GMT+00:00) London")
  end
end
