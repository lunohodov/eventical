class Analytics::Counter < ApplicationRecord
  self.table_name = "analytics_counters"

  belongs_to :owner, polymorphic: true, optional: true

  validates :topic, presence: true
  validates :value, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def increment!
    super(:value, touch: true)
  end
end
