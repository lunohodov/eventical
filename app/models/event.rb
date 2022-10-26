class Event < ApplicationRecord
  self.ignored_columns += %w[
    character_id
    details_updated_at
    owner_category
    owner_name
    owner_uid
  ]

  belongs_to :character, foreign_key: :character_owner_hash, primary_key: :owner_hash

  validates :starts_at, presence: true
  validates :title, presence: true
  validates :uid, presence: true

  def self.upcoming
    where("starts_at >= ?", Time.current)
  end

  def self.upcoming_for(character)
    upcoming.where(character: character)
  end

  def self.in_chronological_order
    order(starts_at: :asc)
  end

  def self.synchronize(data_source)
    character = data_source.character

    attributes = {
      importance: data_source.importance,
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
