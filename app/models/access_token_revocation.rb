class AccessTokenRevocation
  include ActiveModel::Validations

  validates :issuer, presence: true
  validates :grantee, presence: true

  def initialize(access_token)
    @issuer = access_token.issuer
    @grantee = access_token.grantee
  end

  def call
    validate!

    AccessToken.transaction do
      AccessToken.
        where(issuer: issuer, grantee: grantee, revoked_at: nil).
        lock.
        update_all(revoked_at: Time.current)

      AccessToken.create!(issuer: issuer, grantee: grantee)
    end
  end

  private

  attr_reader :issuer
  attr_reader :grantee
end
