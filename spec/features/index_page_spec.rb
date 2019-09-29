require "rails_helper"

describe "home index page" do
  it "displays promotional content" do
    visit "/"

    expect(page).to have_content("Convenient out-of-game access to your EVE Online calendar")
    expect(page).to have_content("Side by side, not aside")
  end

  it "links to login page" do
    visit "/"

    expect(page).to have_button("Log in with EVE Online", count: 3)
  end

  it "links to about page" do
    visit "/"

    expect(find_link("About")).to be_visible
  end
end
