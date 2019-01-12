require "rails_helper"

describe "home index page" do
  it "displays promotional content" do
    visit "/"

    expect(page).to have_content("out-of-game access")
    expect(page).to have_content("everyone in the loop")
    expect(page).to have_content("always in control")
  end

  it "links to login page" do
    visit "/"

    within(".cover-try") do
      expect(find_link("Log in with EVE Online")).to be_visible
    end

    within(".masthead") do
      expect(find_link("Log in with EVE Online")).to be_visible
    end
  end

  it "links to about page" do
    visit "/"

    expect(find_link("About")).to be_visible
  end
end
