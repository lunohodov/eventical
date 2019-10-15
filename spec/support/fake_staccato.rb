class FakeStaccato
  class EventsList
    def initialize(events)
      @events = events
    end

    def <<(event)
      events << event
    end

    def events_for(user)
      self.class.new(
        events.select { |e| e[:user_id] == user.id },
      )
    end

    def named(event_name)
      self.class.new(
        events.select { |e| e[:action] == event_name },
      )
    end

    def has_properties?(options)
      events.any? do |event|
        options.all? { |key, value| event[key] == value }
      end
    end

    private

    attr_reader :events
  end

  attr_reader :tracked_events

  def initialize
    @tracked_events = EventsList.new([])
  end

  def event(options)
    tracked_events << options
  end

  def tracked_events_for(user)
    tracked_events.events_for(user)
  end
end
