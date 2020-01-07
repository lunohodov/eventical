require "securerandom"

class AccessToken < ApplicationRecord
  belongs_to :issuer, class_name: "Character"
  belongs_to :grantee, polymorphic: true, optional: true

  validate :event_owner_categories_must_be_valid

  before_create :generate_token_if_needed

  scope :personal, ->(c) { where(issuer: c, grantee: c) }
  scope :current, -> {
    where("expires_at > ? OR expires_at IS NULL", Time.current).
      where(revoked_at: nil)
  }

  class << self
    def by_slug!(slug)
      find_by!(token: parse_slug(slug))
    end

    def create_personal!(char)
      create!(issuer: char, grantee: char)
    end

    def revoke!(access_token)
      raise "Access token must be persisted" unless access_token.persisted?

      where(issuer: access_token.issuer,
            grantee: access_token.grantee,
            revoked_at: nil).
        lock.
        update_all(revoked_at: Time.current)
    end

    private

    def parse_slug(slug)
      slug.sub(/(private|public)-/i, "")
    end
  end

  def slug
    if personal?
      "private-#{token}"
    else
      "public-#{token}"
    end
  end

  def to_param
    slug
  end

  def personal?
    issuer == grantee
  end

  def public?
    grantee.nil?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  private

  def event_owner_categories_must_be_valid
    return true if event_owner_categories.blank?

    if event_owner_categories.any? { |e| !Event::OWNER_CATEGORIES.include?(e) }
      errors.add(:event_owner_categories, :invalid)
    end
  end

  def generate_token_if_needed
    self.token = SecureRandom.uuid if token.blank?
  end
end
