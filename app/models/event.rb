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

    attributes = {
      importance: data_source.importance,
      owner_category: data_source.owner_category,
      owner_name: data_source.owner_name,
      owner_uid: data_source.owner_uid,
      response: data_source.response,
      starts_at: data_source.starts_at,
      title: data_source.title
    }

    # Not atomic and has a race condition between SELECT and INSERT.
    # Yet, duplicate records are not a concern as there is a unique index
    # on `character_id` and `uid`.
    Event.find_or_create_by!(character: character, uid: data_source.uid) do |e|
      e.assign_attributes(attributes)
    end.tap do |e|
      e.assign_attributes(attributes)
      e.save!
    end
  end
end
