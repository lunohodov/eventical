class Event < ApplicationRecord
  belongs_to :character

  validates :starts_at, presence: true
  validates :title, presence: true
  validates :uid, presence: true
end
