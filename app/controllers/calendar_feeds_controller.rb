require "icalendar/tzinfo"

class CalendarFeedsController < ApplicationController
  PAGE_SIZE = 50
  CACHE_EXPIRES_IN = 90.minutes

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    character = access_token.issuer

    events = upcoming_events(character)

    render_headers

    respond_to do |format|
      format.ics do
        render_ical(events)
      end
      format.html do
        @events = events
        @time_zone = preferred_time_zone
        @access_token = access_token
      end
    end
  end

  private

  def upcoming_events(character)
    Event.upcoming_for(character).limit(PAGE_SIZE)
  end

  def access_token
    @access_token ||= AccessToken.by_slug!(params[:id])
  end

  def preferred_time_zone
    @preferred_time_zone ||= resolve_time_zone
  end

  def resolve_time_zone
    time_zone = if params[:tz].present?
                  ActiveSupport::TimeZone[params[:tz]]
                else
                  Setting.for_character(access_token.grantee).time_zone
                end
    time_zone.presence || Eve.time_zone
  end

  def render_ical(events)
    send_data to_ical(events),
              filename: "basic.ics",
              type: "text/calendar; charset=utf-8",
              disposition: :inline
  end

  def to_ical(events)
    issuer = access_token.issuer
    recipient = access_token.grantee

    cal = Icalendar::Calendar.new

    # Modern calendar applications such as Google Calendar, Apple Calendar
    # and their mobile variants convert to the right time zone automatically.
    #
    # Export iCal in UTC (i.e EVE time) and leave conversion to the client
    # application.
    #
    tz = Eve.time_zone.tzinfo

    unless events.empty?
      sample_time = events.first.starts_at
      cal.add_timezone tz.ical_timezone(sample_time)
    end

    events.each do |event|
      cal.event do |e|
        e.dtstart = Icalendar::Values::DateTime.new(
          event.starts_at,
          "tzid" => tz.identifier,
        )
        e.summary = event.title
        # Status relates to event itself i.e confirmed by organizer.
        e.status = "CONFIRMED"
      end
    end

    {
      "X-WR-CALNAME" => "#{issuer.name}'s Calendar",
      "X-WR-CALDESC" => "Upcoming events for #{recipient.name}",
      "X-WR-TIMEZONE" => tz.identifier,
      "X-APPLE-CALENDAR-COLOR" => "#9A9CFF",
    }.each do |prop_name, prop_value|
      cal.append_custom_property(prop_name, prop_value)
    end

    # TODO
    cal.prodid = "eventical"
    cal.publish

    cal.to_ical
  end

  def render_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = Time.utc(1990, 1, 1).rfc2822
    response.headers["Date"] = Time.current.utc.rfc2822
  end

  def record_not_found
    render plain: "404 Not Found", status: 404
  end
end
