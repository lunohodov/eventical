require "securerandom"

class AccessToken < ApplicationRecord
  belongs_to :issuer, class_name: "Character"
  belongs_to :grantee, polymorphic: true

  before_create :generate_token

  scope :personal, ->(c) { where(issuer: c, grantee: c) }
  scope :current, -> {
    where("expires_at > ? OR expires_at IS NULL", Time.current).
      where(revoked_at: nil)
  }

  class << self
    def by_slug!(slug)
      current.find_by!(token: parse_slug(slug))
    end

    def create_personal!(char)
      create!(issuer: char, grantee: char)
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

  def shared?
    !personal?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  private

  def generate_token
    self.token = SecureRandom.uuid
  end
end
