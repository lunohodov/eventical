# frozen_string_literal: true

class Analytics::InMemoryBackend < Analytics::Backend
  attr_reader :counters

  def initialize
    @counters = []
  end

  def find_all(event, resource:)
    counters.find_all { |c| c.topic == event && c.owner == resource }
  end

  def count(event, resource:)
    matched_counters = find_all(event, resource: resource)

    if matched_counters.empty?
      counters << new_counter(topic: event, owner: resource, value: 1)
    else
      matched_counters.each do |c|
        c.increment(:value)
        c.updated_at = Time.current
      end
    end
  end

  private

  def new_counter(overrides = {})
    attributes = {value: 0, created_at: Time.current}.merge(overrides)
    # Prevent accidental persistence to the database
    Analytics::Counter.new(attributes).tap(&:readonly!)
  end
end
