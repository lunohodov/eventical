class Character < ApplicationRecord
  has_many :events

  validates :uid, presence: true
  validates :name, presence: true
  validates :owner_hash, presence: true
  validates :token, presence: true

  def token_expired?
    token_expires_at?(Time.current)
  end

  def token_expires_at?(time)
    token_expires_at.nil? || time >= token_expires_at
  end
end
