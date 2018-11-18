class Character < ApplicationRecord
  has_many :events

  validates :name, presence: true
  validates :owner_hash, presence: true
  validates :refresh_token, presence: true
  validates :token, presence: true

  def token_expired?
    token_expires_at.present? && Time.now > token_expires_at
  end
end
