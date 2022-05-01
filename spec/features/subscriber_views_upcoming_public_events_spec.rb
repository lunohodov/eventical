require "rails_helper"

feature "Subscriber views upcoming public events", type: :feature do
  scenario "and sees events grouped by date" do
    access_token = create_access_token
    event = create(:event, :public, character: access_token.issuer)

    visit_feed_path(access_token)

    within date_group_selector(event.starts_at) do
      expect(page).to have_event_details(event)
    end
  end

  scenario "and sees time in given time zone" do
    access_token = create_access_token
    character = access_token.issuer
    event = create(:event, :public, character: character, starts_at: 1.month.from_now)

    visit_feed_path(access_token, time_zone: "Sofia")

    within("tr.event") do
      expect(page).to have_content(
        event.starts_at.in_time_zone("Sofia").strftime("%H:%M")
      )
    end
  end

  scenario "and sees informative text, when there are no upcoming events" do
    visit_feed_path(create_access_token)

    expect(page).not_to have_events
    expect(page).to have_content(/no upcoming events/i)
  end

  scenario "and sees iCal link, when there are no upcoming events" do
    visit_feed_path(create_access_token)

    expect(page).not_to have_events
    expect(page).to have_ical_link
  end

  scenario "and sees link to iCal feed" do
    access_token = create_access_token
    character = access_token.issuer
    create(:event, character: character, starts_at: 1.day.from_now)

    visit_feed_path(access_token)

    expect(page).to have_ical_link
  end

  scenario "and does not see private events" do
    access_token = create_access_token
    create(:event, character: access_token.issuer)
    create(:event, :corporate, character: access_token.issuer)
    create(:event, :faction, character: access_token.issuer)
    create(:event, :alliance, character: access_token.issuer)
    create(:event, :ccp, character: access_token.issuer)

    visit_feed_path(access_token)

    expect(page).not_to have_events
  end

  scenario "and does not see public events from other entities" do
    access_token = create_access_token
    create(:event, :public, :corporate, character: access_token.issuer)
    create(:event, :public, :faction, character: access_token.issuer)
    create(:event, :public, :alliance, character: access_token.issuer)
    create(:event, :public, :ccp, character: access_token.issuer)

    visit_feed_path(access_token)

    expect(page).not_to have_events
  end

  def visit_feed_path(access_token, time_zone: nil)
    visit public_feeds_path(id: access_token.token, params: {tz: time_zone})
  end

  def create_access_token(character = nil)
    create(
      :access_token,
      :public,
      issuer: character || create(:character)
    )
  end

  def date_group_selector(date)
    ".event-list[data-date=\"#{date.strftime("%Y-%m-%d")}\"]"
  end

  matcher :have_events do
    match do |page|
      !page.has_css?("tr.event", count: 0)
    end
  end

  matcher :have_ical_link do
    match do |page|
      expect(page).to have_link("iCal")
    end
  end

  matcher :have_event_details do |e|
    match do |page|
      page.has_content?(e.starts_at.strftime("%H:%M")) &&
        page.has_content?(e.title) &&
        page.has_content?(e.starts_at.utc.strftime("%Y-%m-%d %H:%M"))
    end
  end
end
