require "icalendar/tzinfo"

class CalendarFeedsController < ApplicationController
  PAGE_SIZE = 50

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    track_access_token_used

    if access_token.revoked? || access_token.expired?
      record_not_found
      return
    end

    character = access_token.issuer
    events = upcoming_events(character, public_only: access_token.public?)

    render_headers

    respond_to do |format|
      format.ics do
        render_ical(build_ical(events))
      end
      format.html do
        @events = events
        @time_zone = preferred_time_zone
        @access_token = access_token
      end
    end
  end

  private

  def track_access_token_used
    character = if access_token.public?
                  access_token.issuer
                else
                  access_token.grantee
                end
    analytics_for(character).
      track_access_token_used(access_token, consumer: consumer)
  end

  def upcoming_events(character, public_only: false)
    result = Event.upcoming_for(character)
    result = result.public if public_only
    result.limit(PAGE_SIZE)
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
                elsif access_token.grantee
                  Setting.for_character(access_token.grantee)&.time_zone
                end
    time_zone.presence || Eve.time_zone
  end

  def render_ical(ical_representation)
    send_data ical_representation,
              filename: "basic.ics",
              type: "text/calendar; charset=utf-8",
              disposition: :inline
  end

  def build_ical(events)
    issuer = access_token.issuer
    grantee = access_token.grantee

    IcalendarBuilder.build do
      calendar_name("#{issuer.name}'s Calendar")
      calendar_description("Upcoming events for #{grantee.name}")
      events(events)
    end
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

  def consumer
    request.headers["User-Agent"]
  end
end
