require "rails_helper"

feature "user views calendar", type: :feature do
  before { sign_in }

  scenario "and sees Google Calendar export option" do
    access_token = create(:access_token, :personal, issuer: current_character)

    visit secret_token_path

    expect(page).to have_link("Google Calendar", href: "#")
    expect(page).to have_field(with: /#{access_token.token}\.ics$/)
  end

  scenario "and sees Apple Calendar export option" do
    access_token = create(:access_token, :personal, issuer: current_character)

    visit secret_token_path

    expect(page).to have_link("Apple Calendar", href: /#{access_token.token}\.ics$/)
  end

  scenario "and sees Outlook export option" do
    access_token = create(:access_token, :personal, issuer: current_character)

    visit secret_token_path

    expect(page).to have_link("Outlook", href: /#{access_token.token}\.ics$/)
  end

  scenario "and sees browser export option" do
    access_token = create(:access_token, :personal, issuer: current_character)

    visit secret_token_path

    expect(page).to have_link("Browser", href: /#{access_token.token}$/)
  end

  scenario "and sees a button to reset the private address" do
    create(:access_token, :personal, issuer: current_character)

    visit secret_token_path

    expect(page).to have_link("reset it")
  end

  scenario "and can change preferred time zone" do
    create(:access_token, :personal, issuer: current_character)

    visit secret_token_path

    select("London", from: :time_zone)
    click_on("Update time zone")

    expect(page).to have_select(:time_zone, selected: "(GMT+00:00) London")
  end

  context "without an issued personal access token" do
    scenario "sees onboarding step" do
      visit secret_token_path

      expect(page).to have_selector(".onboarding-steps")
    end
  end
end
