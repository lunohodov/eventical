class AccessToken < ApplicationRecord
  belongs_to :issuer, class_name: "Character"
  belongs_to :grantee, polymorphic: true, optional: true

  validates :character_owner_hash, presence: true, allow_blank: false

  before_create :generate_token_if_needed
  before_validation :ensure_character_owner_hash

  scope :current, -> {
    where("expires_at > ? OR expires_at IS NULL", Time.current)
      .where(revoked_at: nil)
  }

  def self.private
    where("issuer_id = grantee_id")
  end

  def self.public
    where(grantee: nil)
  end

  class << self
    def by_slug!(slug)
      where(token: slug).last!
    end

    def revoke!(access_token)
      raise "Access token must be persisted" unless access_token.persisted?

      where(
        issuer: access_token.issuer,
        grantee: access_token.grantee,
        revoked_at: nil
      ).lock.update_all(revoked_at: Time.current)
    end
  end

  def slug
    token
  end

  def to_param
    slug
  end

  def private?
    issuer == grantee
  end

  def public?
    grantee.nil?
  end

  def revoked?
    revoked_at.present?
  end

  private

  def generate_token_if_needed
    self.token = SecureRandom.uuid if token.blank?
  end

  def ensure_character_owner_hash
    self.character_owner_hash = issuer&.owner_hash if character_owner_hash.blank?
  end
end
