# frozen_string_literal: true

module Eve
  def self.time_zone
    ActiveSupport::TimeZone["UTC"]
  end
end
