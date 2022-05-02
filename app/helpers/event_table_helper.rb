module EventTableHelper
  TIME_FORMAT = "%H:%M"
  DATE_TIME_FORMAT = "%Y-%m-%d %H:%M"

  def event_table(events, local_time_zone: Eve.time_zone)
    events_by_date = events.chunk { |e| e.starts_at.in_time_zone(local_time_zone).midnight }

    render partial: "shared/event_table", locals: {
      events_by_date: events_by_date,
      local_time_zone: local_time_zone
    }
  end

  def eve_time_tag(date_time)
    eve_time = date_time.in_time_zone(Eve.time_zone)

    time_tag(eve_time) do
      eve_time.strftime(DATE_TIME_FORMAT)
    end
  end

  def local_time_tag(date_time, time_zone)
    local_time = date_time.in_time_zone(time_zone)

    time_tag(local_time) do
      local_time.strftime(TIME_FORMAT)
    end
  end
end
