require "rails_helper"

feature "user views calendar", type: :feature do
  scenario "and sees it's private address" do
    sign_in

    access_token = create(:access_token, :personal, issuer: current_character)

    visit calendar_path

    expect(page).to have_link(href: /#{access_token.token}$/)
  end

  scenario "and sees a button to reset the private address" do
    sign_in

    create(:access_token, :personal, issuer: current_character)

    visit calendar_path

    expect(page).to have_button("Reset secret address")
  end
end
