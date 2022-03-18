# frozen_string_literal: true

require "icalendar/tzinfo"

class IcalendarBuilder
  ATTRIBUTES = %i[
    calendar_name
    calendar_description
    events
  ].freeze

  attr_reader :attributes

  def initialize
    @attributes = {}
  end

  def self.build(&block)
    builder = new
    builder.instance_eval(&block)
    builder.to_ical
  end

  def respond_to_missing?(name, _include_all)
    ATTRIBUTES.include?(name)
  end

  def method_missing(name, *args, &_block)
    attributes[name] = args[0]
  end
  # rubocop:enable Style/MethodMissingSuper

  def to_ical
    cal = Icalendar::Calendar.new

    # Modern calendar applications such as Google Calendar, Apple Calendar
    # and their mobile variants convert to the right time zone automatically.
    #
    # Export iCal in UTC (i.e EVE time) and leave conversion to the client
    # application.
    #
    tz = Eve.time_zone.tzinfo

    events = attributes.fetch(:events, [])
    unless events.empty?
      sample_time = events.first.starts_at
      cal.add_timezone tz.ical_timezone(sample_time)
    end

    events.each do |event|
      cal.event do |e|
        e.dtstart = Icalendar::Values::DateTime.new(
          event.starts_at,
          "tzid" => tz.identifier
        )
        e.summary = event.title
        # Status relates to event itself i.e confirmed by organizer.
        e.status = "CONFIRMED"
      end
    end

    {
      "X-WR-CALNAME" => attributes.fetch(:calendar_name, ""),
      "X-WR-CALDESC" => attributes.fetch(:calendar_description, ""),
      "X-WR-TIMEZONE" => tz.identifier
    }.each do |prop_name, prop_value|
      cal.append_custom_property(prop_name, prop_value)
    end

    # TODO
    cal.prodid = "eventical"
    cal.publish

    cal.to_ical
  end
end
