class Character < ApplicationRecord
  has_many :events
  has_many :issued_access_tokens, as: :issuer
  has_many :granted_access_tokens, as: :grantee

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

  def token_expires_at?(time)
    token_expires_at.nil? || time >= token_expires_at
  end
end
