RSpec::Matchers.define :have_tracked do |event_name|
  match do |analytics_backend|
    @event_name = event_name
    @analytics_backend = analytics_backend

    events =
      if @character.present?
        analytics_backend.tracked_events_for(@character)
      else
        analytics_backend.tracked_events
      end

    events
      .named(@event_name)
      .has_properties?(@properties || {})
  end

  chain(:for_character) { |character| @character = character }
  chain(:with_properties) { |properties| @properties = properties }
end
