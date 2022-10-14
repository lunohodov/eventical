require "rails_helper"

feature "Subscriber resets secret address", type: :feature do
  before { sign_in }

  scenario "and makes current address invalid" do
    access_token = create(:access_token, character: current_character)

    visit secret_calendar_path
    click_reset_button

    expect(page).not_to have_field(with: /#{access_token.token}\.ics$/)
    expect(page).not_to have_link(href: /#{access_token.token}/)
  end

  scenario "and receives a new address" do
    create(:access_token, character: current_character)

    visit secret_calendar_path
    click_reset_button

    access_token = AccessToken.for(current_character)

    expect(page).to have_field(with: /#{access_token.token}\.ics$/)
    expect(page).to have_link(href: /#{access_token.token}$/)
  end

  scenario "and triggers revocation analytics event" do
    create(:access_token, character: current_character)

    visit secret_calendar_path
    click_reset_button

    expect(analytics).to have_tracked("access_token.revoked")
  end

  def click_reset_button
    click_on("reset it")
  end
end
