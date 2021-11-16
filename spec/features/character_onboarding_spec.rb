require "rails_helper"

feature "Character onboarding", type: :feature do
  scenario "starts when a character signs up" do
    sign_in_as build(:character)

    expect(page).to have_selector(".onboarding-steps")

    click_button "Create feed"

    expect(page).to have_text("Your Secret Feed")
  end
end
