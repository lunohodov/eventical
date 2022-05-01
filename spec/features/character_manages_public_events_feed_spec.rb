require "rails_helper"

feature "Character manages public feed", type: :feature do
  before { sign_in }

  scenario "and can enable it" do
    visit public_calendar_url
    click_on "Start publishing"

    expect(page).to have_text(/Feed published/)
    expect(page).to have_link("Stop publishing")
  end

  scenario "and can disable it" do
    create(:access_token, :public, issuer: current_character)

    visit public_calendar_url
    click_on "Stop publishing"

    expect(page).to have_text(/Nothing published/)
    expect(page).to have_link("Start publishing")
  end
end
