class Event < ApplicationRecord
  belongs_to :character

  validates :starts_at, presence: true
  validates :title, presence: true
  validates :uid, presence: true

  def self.upcoming_for(character)
    where(character: character).
      where("starts_at >= ?", Date.current).
      order(starts_at: :asc)
  end
end
