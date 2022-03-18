class AccessToken < ApplicationRecord
  belongs_to :issuer, class_name: "Character"
  belongs_to :grantee, polymorphic: true, optional: true

  before_create :generate_token_if_needed

  scope :current, -> {
    where("expires_at > ? OR expires_at IS NULL", Time.current)
      .where(revoked_at: nil)
  }

  def self.private
    where("issuer_id = grantee_id")
  end

  class << self
    def by_slug!(slug)
      where(token: parse_slug(slug)).last!
    end

    def revoke!(access_token)
      raise "Access token must be persisted" unless access_token.persisted?

      where(
        issuer: access_token.issuer,
        grantee: access_token.grantee,
        revoked_at: nil
      ).lock.update_all(revoked_at: Time.current)
    end

    private

    def parse_slug(slug)
      slug.sub(/(private|public)-/i, "")
    end
  end

  def slug
    if private?
      "private-#{token}"
    else
      "public-#{token}"
    end
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
end
