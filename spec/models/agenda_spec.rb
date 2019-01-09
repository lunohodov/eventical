require "rails_helper"

describe Agenda do
  it "is Enumerable" do
    expect(Agenda).to include(Enumerable)
  end

  it "sorts events by date (earliest first)" do
    events = [
      build(:event, starts_at: Time.current),
      build(:event, starts_at: 1.day.from_now),
    ]

    agenda = Agenda.new(events: events)
    agenda_dates = agenda.entries.map(&:date)

    expect(agenda_dates).to match_array(
      events.map { |e| e.starts_at.to_date }.sort,
    )
  end

  it "groups events by date" do
    events = [
      build(:event, starts_at: Time.current),
      build(:event, starts_at: 1.day.from_now),
    ]

    entries = Agenda.new(events: events).entries

    expect(entries.count).to eq(2)
    expect(entries[0].date).to eq(events[0].starts_at.to_date)
    expect(entries[0].events).to match_array([events.first])
  end
end
