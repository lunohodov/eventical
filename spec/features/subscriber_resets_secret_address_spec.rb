require "rails_helper"

feature "subscriber resets secret address", type: :feature do
  before { sign_in }

  scenario "and makes current address invalid" do
    access_token = create(:access_token, :personal, issuer: current_character)

    visit calendar_path
    click_reset_button

    within "#secret-address" do
      expect(page).not_to have_link(href: /#{access_token.token}$/)
    end
  end

  scenario "and receives a new address" do
    create(:access_token, :personal, issuer: current_character)

    visit calendar_path
    click_reset_button

    access_token = AccessToken.personal(current_character).current.last

    within "#secret-address" do
      expect(page).to have_link(href: /#{access_token.token}$/)
    end
  end

  def click_reset_button
    click_on("Reset secret address")
  end
end
