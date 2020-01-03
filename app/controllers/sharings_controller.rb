class SharingsController < ApplicationController
  def show
    @public_events_feed = OpenStruct.new(
      ical_url: sharing_url(nil, format: :ics, protocol: "webcal"),
      browser_url: sharing_url,
      enabled?: (Time.current.to_i % 2).zero?,
    )
  end
end
