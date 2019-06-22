# frozen_string_literal: true

module Eve
  module ClassMethods
    def time_zone
      ActiveSupport::TimeZone["UTC"]
    end
  end

  extend ClassMethods
end
