class Event < ApplicationRecord
  belongs_to :character

  validates :starts_at, presence: true
  validates :title, presence: true
  validates :uid, presence: true
  validates :character_owner_hash, presence: true, allow_blank: false

  before_validation :ensure_character_owner_hash

  def self.upcoming
    where("starts_at >= ?", Time.current)
  end

  def self.upcoming_for(character)
    upcoming.where(character: character)
  end

  def self.public
    where("title LIKE '[PUBLIC]%'")
  end

  def self.public_by(character)
    upcoming
      .public
      .owned_by(character)
      .where(character: character)
  end

  def self.owned_by(character)
    where(owner_category: "character", owner_uid: character.uid)
  end

  def self.in_chronological_order
    order(starts_at: :asc)
  end

  def self.without_details
    where(details_updated_at: nil)
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

  private

  def ensure_character_owner_hash
    self.character_owner_hash = character&.owner_hash if character_owner_hash.blank?
  end
end
