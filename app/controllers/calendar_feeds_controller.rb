class CalendarFeedsController < ApplicationController
  PAGE_SIZE = 50

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  around_action :set_time_zone

  before_action do
    # TODO: Move this out of here
    authenticate
    ensure_valid_character_access_token
  end

  after_action :remember_preferred_time_zone

  def show
    @calendar = character_calendar(access_token.issuer)
    render_headers
  end

  private

  def character_calendar(character)
    # TODO: Think about proper event synchronization
    EventSynchronization.new(character: character).call

    Calendar.new(
      events: upcoming_events(character),
      time_zone: preferred_time_zone,
    )
  end

  def upcoming_events(character)
    Event.
      upcoming_for(character).
      limit(PAGE_SIZE)
  end

  def access_token
    @access_token ||= AccessToken.find_granted_by_slug!(
      slug: params[:id],
      grantee: current_character,
    )
  end

  def ensure_valid_character_access_token
    CharacterAccessToken.new(current_character).refresh
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

  # def render_ical(calendar)
  #   send_data generate_feed(calendar),
  #     filename: "basic.ics",
  #     type: "text/calendar; charset=utf-8",
  #     disposition: :inline
  # end

  def generate_feed(calendar, time_zone)
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

  def record_not_found
    render plain: "404 Not Found", status: 404
  end
end
