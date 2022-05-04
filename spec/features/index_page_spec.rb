require "rails_helper"

describe "home index page" do
  it "displays promotional content" do
    visit "/"

    expect(page).to have_content("Convenient out-of-game access to your EVE Online calendar")
    expect(page).to have_content("Side by side, not aside")
  end

  it "links to login page" do
    visit "/"

    expect(page).to have_button("Log in with EVE Online", count: 2)
  end

  it "links to about page" do
    visit "/"

    expect(find_link("About")).to be_visible
  end

  context "with logged in character" do
    before { sign_in }

    it "does not link to login page" do
      visit "/"

      expect(page).not_to have_button("Log in with EVE Online")
    end

    it "shows link to character's calendar page" do
      visit "/"

      expect(page).to have_link(href: secret_calendar_url)
    end
  end
end
