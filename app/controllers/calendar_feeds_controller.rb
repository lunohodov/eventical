require "ostruct"

class CalendarFeedsController < ApplicationController
  def show
    render_headers

    character = Event.last&.character
    calendar = Calendar.new(character)

    respond_to do |format|
      format.html { render :show, locals: { calendar: calendar } }
      format.ical { render_ical(calendar) }
    end
  end

  private

  def render_ical(calendar)
    send_data generate_feed(calendar),
      filename: "basic.ics",
      type: "text/calendar; charset=utf-8",
      disposition: :inline
  end

  def generate_feed(calendar)
    buffer = []

    buffer << "BEGIN:VCALENDAR"
    buffer << "VERSION:2.0"
    buffer << "PRODID:eventical"
    buffer << "CALSCALE:GREGORIAN"
    buffer << "METHOD:PUBLISH"
    # buffer << "X-WR-CALNAME:#{calendar.display_name}"
    # buffer << "X-WR-TIMEZONE;VALUE=TEXT:#{calendar.time_zone.name}"
    # buffer << "LAST-MODIFIED:#{format_datetime(calendar.last_modified_at)}"
    #   BEGIN:VEVENT
    #   DTSTAMP:20181216T074451Z
    #   UID:a4359af6-dc68-451e-a415-074c721858d8
    #   DTSTART:20181216T074451
    #   SUMMARY:Robyn Dibbert
    #   END:VEVENT
    #   END:VCALENDAR
    buffer << "END:VCALENDAR"

    buffer.compact.join("\r\n")
  end

  def render_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = Time.utc(1990, 1, 1).rfc2822
    response.headers["Date"] = Time.current.utc.rfc2822
  end

  def format_datetime(value)
    value.strftime("%Y%m%dT%H%M%S")
  end
end
