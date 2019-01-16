class Calendar
  attr_reader :events
  attr_reader :time_zone

  delegate :empty?, to: :events

  def initialize(events: [], time_zone: Time.zone)
    @events = events
    @time_zone = time_zone
  end

  def agenda
    @agenda ||= Agenda.new(events: events)
  end
end
