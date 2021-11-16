class Event < ApplicationRecord
  belongs_to :character

  validates :starts_at, presence: true
  validates :title, presence: true
  validates :uid, presence: true

  def self.upcoming_for(character, since: nil)
    since ||= Date.current
    where(character: character)
      .where("starts_at >= ?", since)
      .order(starts_at: :asc)
  end

  def self.public_by(character, since: nil)
    since ||= Date.current
    where(character: character)
      .where("starts_at >= ?", since)
      .where("title LIKE '[PUBLIC]%'")
      .where(owner_category: "character", owner_uid: character.uid)
      .order(starts_at: :asc)
  end

  def self.synchronize(data_source)
    character = data_source.character

    event = Event.lock.where(uid: data_source.uid, character: character).first
    if event.nil?
      event = Event.new(character: character, uid: data_source.uid)
    end

    %i[
      importance
      owner_category
      owner_name
      owner_uid
      response
      starts_at
      title
    ].each do |attr|
      value = data_source.public_send(attr).presence
      event[attr] = value if value
    end

    event.save!
  end
end
