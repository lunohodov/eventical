class AccessToken < ApplicationRecord
  self.ignored_columns += %w[
    event_owner_categories
    expires_at
    grantee_id
    grantee_type
    issuer_id
  ]

  belongs_to :character, foreign_key: :character_owner_hash, primary_key: :owner_hash

  before_create :generate_token_if_needed

  def self.current
    where(revoked_at: nil)
  end

  class << self
    def for(character)
      current.where(character: character).last
    end

    def revoke!(access_token)
      raise "Access token must be persisted" unless access_token.persisted?

      where(
        character: access_token.character,
        revoked_at: nil
      ).lock.update_all(revoked_at: Time.current)
    end
  end

  def to_param
    token
  end

  def revoked?
    revoked_at.present?
  end

  private

  def generate_token_if_needed
    self.token = SecureRandom.uuid if token.blank?
  end
end
