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
