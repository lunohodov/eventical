class AccessTokenRevocation
  include ActiveModel::Validations

  attr_reader :access_token

  validates :access_token, presence: true

  def initialize(access_token)
    @access_token = access_token
  end

  def call
    validate!

    AccessToken.transaction do
      AccessToken.revoke!(access_token)

      AccessToken.create!(
        issuer: access_token.issuer,
        grantee: access_token.grantee,
      )
    end
  end
end
