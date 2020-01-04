require "rails_helper"

feature "character enables public events feed", type: :feature do
  before { sign_in }

  scenario "and sees status" do
    visit sharing_url

    click_on "Start publishing"

    expect(page).to have_text("Feed is published and subscribers can see your public events")
    expect(page).to have_button("Stop publishing")
  end

  scenario "and sees explanation about which events are public" do
    visit sharing_url

    expect(page).to have_text("title prefixed with [PUBLIC]")
    expect(page).to have_text("personal i.e created with the Personal radio button checked")
  end
end
