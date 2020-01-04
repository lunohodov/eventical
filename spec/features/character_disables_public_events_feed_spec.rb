require "rails_helper"

feature "character disables public events feed", type: :feature do
  before { sign_in }

  scenario "and sees status" do
    create(:access_token, :public, issuer: current_character)

    visit sharing_url

    click_on "Stop publishing"

    expect(page).to have_text("Nothing is published and nobody can see your events")
    expect(page).to have_button("Start publishing")
  end
end
