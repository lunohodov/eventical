require "rails_helper"

feature "Public events feed management", type: :feature do
  before { sign_in }

  scenario "enabling" do
    visit sharing_url
    click_on "Start publishing"

    expect(page).to have_text(/Feed published/)
    expect(page).to have_link("Stop publishing")
  end

  scenario "disabling" do
    create(:access_token, :public, issuer: current_character)

    visit sharing_url
    click_on "Stop publishing"

    expect(page).to have_text(/Nothing published/)
    expect(page).to have_link("Start publishing")
  end
end
