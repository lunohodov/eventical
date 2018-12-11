class Character < ApplicationRecord
  has_many :events

  validates :uid, presence: true
  validates :name, presence: true
  validates :owner_hash, presence: true
  validates :token, presence: true

  def token_expired?
    token_expires_at.present? && Time.now > token_expires_at
  end
end
