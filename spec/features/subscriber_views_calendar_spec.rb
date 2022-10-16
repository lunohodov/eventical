require "rails_helper"

feature "user manages her secret feed", type: :feature do
  before { sign_in }

  scenario "and sees a Google Calendar option" do
    access_token = create(:access_token, character: current_character)

    visit secret_calendar_path

    expect(page).to have_link("Google Calendar", href: "#")
    expect(page).to have_field(with: /#{access_token.token}\.ics$/)
  end

  scenario "and sees an Apple Calendar option" do
    access_token = create(:access_token, character: current_character)

    visit secret_calendar_path

    expect(page).to have_link("Apple Calendar", href: /#{access_token.token}\.ics$/)
  end

  scenario "and sees an Outlook Calendar option" do
    access_token = create(:access_token, character: current_character)

    visit secret_calendar_path

    expect(page).to have_link("Outlook", href: /#{access_token.token}\.ics$/)
  end

  scenario "and sees a browser option" do
    access_token = create(:access_token, character: current_character)

    visit secret_calendar_path

    expect(page).to have_link("Browser", href: /#{access_token.token}$/)
  end

  scenario "and sees a reset button" do
    create(:access_token, character: current_character)

    visit secret_calendar_path

    expect(page).to have_link("reset it")
  end

  scenario "and can change the preferred time zone" do
    create(:access_token, character: current_character)

    visit secret_calendar_path

    select("London", from: :time_zone)
    click_on("Update time zone")

    expect(page).to have_select(:time_zone, selected: "(GMT+00:00) London")
  end

  context "without a personal access token" do
    scenario "sees the onboarding screen" do
      visit secret_calendar_path

      expect(page).to have_selector(".onboarding-steps")
    end
  end
end
