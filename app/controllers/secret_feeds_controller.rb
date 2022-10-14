require "icalendar/tzinfo"

class SecretFeedsController < ApplicationController
  PAGE_SIZE = 50

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    analytics.track_access_token_used(access_token)

    if access_token.revoked?
      record_not_found
      return
    end

    render_headers

    respond_to do |format|
      format.ics do
        render_ical(build_ical(calendar_events))
      end
      format.html do
        @events = calendar_events
        @time_zone = preferred_time_zone
        @access_token = access_token
      end
    end
  end

  private

  delegate :character, to: :access_token

  def calendar_events
    Event
      .upcoming_for(character)
      .in_chronological_order.limit(PAGE_SIZE)
  end

  def access_token
    @access_token ||= AccessToken.find_by!(token: params[:id])
  end

  def preferred_time_zone
    time_zone =
      if params[:tz].present?
        ActiveSupport::TimeZone[params[:tz]]
      else
        character.time_zone
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
    character_name = character.name
    IcalendarBuilder.build do
      calendar_name("#{character_name}'s Calendar")
      calendar_description("Upcoming events for #{character_name}")
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
    render plain: "404 Not Found", status: :not_found
  end
end
