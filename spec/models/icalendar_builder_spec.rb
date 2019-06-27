require "rails_helper"

require "icalendar/tzinfo"

describe IcalendarBuilder do
  describe ".build" do
    it "sets calendar's name" do
      ical = IcalendarBuilder.build do
        calendar_name "test"
      end

      expect(ical).to match(/X-WR-CALNAME:test/)
    end

    it "sets calendar's description" do
      ical = IcalendarBuilder.build do
        calendar_description "test"
      end

      expect(ical).to match(/X-WR-CALDESC:test/)
    end

    it "sets the time zone" do
      upcoming_events = build_list(:event, 2)

      ical = IcalendarBuilder.build do
        events(upcoming_events)
      end

      expect(ical).to match %r{TZID:Etc/UTC}
      expect(ical).to match %r{TZNAME:UTC}
    end

    it "includes given event" do
      event = build(:event)

      ical = IcalendarBuilder.build do
        events [event]
      end

      expect(ical).to match %r{SUMMARY:#{event.title}}
    end
  end
end
