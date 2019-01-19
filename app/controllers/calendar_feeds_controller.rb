require "icalendar/tzinfo"

class CalendarFeedsController < ApplicationController
  PAGE_SIZE = 50

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  after_action :remember_preferred_time_zone
  around_action :set_time_zone

  def show
    calendar = character_calendar(access_token.issuer)

    render_headers

    respond_to do |format|
      format.ics { render_ical(calendar) }
      format.html { @calendar = calendar }
    end
  end

  private

  def character_calendar(character)
    # TODO: Move this out of here?
    CharacterAccessToken.new(character).refresh
    # TODO: Think about proper event synchronization
    EventSynchronization.new(character: character).call

    Calendar.new(
      events: upcoming_events(character),
      time_zone: preferred_time_zone,
    )
  end

  def upcoming_events(character)
    Event.upcoming_for(character).limit(PAGE_SIZE)
  end

  def access_token
    @access_token ||= AccessToken.by_slug!(params[:id])
  end

  def preferred_time_zone
    zone_name = params[:tz].presence ||
      cookies.signed[:tz].presence ||
      Eve.time_zone.name
    ActiveSupport::TimeZone[zone_name].presence || Eve.time_zone
  end

  def set_time_zone(&block)
    Time.use_zone(preferred_time_zone, &block)
  end

  def remember_preferred_time_zone
    cookies.signed.permanent[:tz] = preferred_time_zone&.name
  end

  def render_ical(calendar)
    send_data to_ical(calendar),
      filename: "basic.ics",
      type: "text/calendar; charset=utf-8",
      disposition: :inline
  end

  def to_ical(calendar)
    issuer = access_token.issuer
    recipient = access_token.grantee

    cal = Icalendar::Calendar.new

    tz = preferred_time_zone.tzinfo
    unless calendar.empty?
      cal.add_timezone tz.ical_timezone(calendar.events.first.starts_at)
    end

    calendar.events.each do |event|
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
