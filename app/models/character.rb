class Character < ApplicationRecord
  has_many :events

  scope :voided, -> { where.not(refresh_token_voided_at: nil) }
  scope :active, -> { where(refresh_token_voided_at: nil) }

  attribute :time_zone, TimeZoneType.new, default: Eve.time_zone

  validates :uid, presence: true
  validates :name, presence: true
  validates :owner_hash, presence: true
  validates :token, presence: true

  def void_refresh_token!
    update!(refresh_token_voided_at: Time.current)
  end

  def refresh_token_voided?
    refresh_token_voided_at.present?
  end

  def token_expired?
    token_expires_at?(Time.current)
  end

  def ensure_token_not_expired!
    Eve::AccessToken.new(self).renew!
  end

  def token_expires_at?(time)
    token_expires_at.nil? || time >= token_expires_at
  end
end
