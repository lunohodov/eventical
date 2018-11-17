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

    expect(find_link("Log in with EVE Online")).to be_visible
  end

  it "links to CCP's copyright notice" do
    visit "/"

    expect(find_link("CCP copyright notice")).to be_visible
  end
end
