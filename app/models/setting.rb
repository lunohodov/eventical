class Setting < ApplicationRecord
  class TimeZoneType < ActiveRecord::Type::Value
    def cast(value)
      case value
      when ActiveSupport::TimeZone
        value
      else
        ActiveSupport::TimeZone.new(value.to_s)
      end
    end

    def serialize(value)
      value&.name
    end
  end

  attribute :time_zone, TimeZoneType.new, default: Eve.time_zone

  def self.for_character(character)
    find_or_create_by(owner_hash: character.owner_hash)
  end
end
