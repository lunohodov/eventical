require "icalendar/tzinfo"

class CalendarFeedsController < ApplicationController
  PAGE_SIZE = 50

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :add_sentry_tags_context

  def show
    character = access_token.issuer

    events = upcoming_events(character)

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

  def record_not_found(err)
    Raven.capture_exception(err, extra: params.to_unsafe_h)
    render plain: "404 Not Found", status: 404
  end

  def add_sentry_tags_context
    consumer = request.headers["User-Agent"]
    Raven.tags_context(consumer: consumer) if consumer.present?
  end
end
