# frozen_string_literal: true

class Analytics::LocalBackend < Analytics::Backend
  def count(event, resource:)
    Analytics::Counter
      .create_or_find_by!(topic: event, owner: resource)
      .increment!(:value, touch: true)
  end
end
