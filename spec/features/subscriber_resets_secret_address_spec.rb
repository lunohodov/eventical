require "rails_helper"

feature "subscriber resets secret address", type: :feature do
  before { sign_in }

  scenario "and makes current address invalid" do
    access_token = create(:access_token, :personal, issuer: current_character)

    visit calendar_path
    click_reset_button

    expect(page).not_to have_field(with: /#{access_token.token}\.ics$/)
    expect(page).not_to have_link(href: /#{access_token.token}/)
  end

  scenario "and receives a new address" do
    create(:access_token, :personal, issuer: current_character)

    visit calendar_path
    click_reset_button

    access_token = AccessToken.personal(current_character).current.last

    expect(page).to have_field(with: /#{access_token.token}\.ics$/)
    expect(page).to have_link(href: /#{access_token.token}$/)
  end

  scenario "and can not access the reset address" do
    initial_token = create(:access_token, :personal, issuer: current_character)

    visit calendar_path
    click_reset_button
    visit calendar_feed_path(id: initial_token.token)

    expect(page).to have_text(/not found/i)
  end

  scenario "and analytics receives a revokation event" do
    create(:access_token, :personal, issuer: current_character)

    visit calendar_path
    click_reset_button

    expect(analytics).to have_tracked("Access token revoked")
  end

  def click_reset_button
    click_on("reset it")
  end
end
