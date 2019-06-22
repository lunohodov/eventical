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

  def self.synchronize(data_source)
    character = data_source.character

    event = Event.lock.where(uid: data_source.uid, character: character).first
    if event.nil?
      event = Event.new(character: character, uid: data_source.uid)
    end

    event.assign_attributes(
      response: data_source.response,
      title: data_source.title,
      starts_at: data_source.starts_at,
    )

    event.save!
  end
end
