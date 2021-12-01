class EventSharing
  attr_reader :character

  def initialize(character)
    @character = character
  end

  def active?
    access_token.present?
  end

  def activate!
    @access_token = AccessToken.create!(
      issuer: character,
      grantee: nil,
      token: public_token_string
    )
  end

  def deactivate!
    AccessToken.revoke!(access_token)
  end

  def toggle!
    if active?
      deactivate!
    else
      activate!
    end
  end

  def access_token
    @access_token ||= AccessToken
      .where(issuer: character, grantee: nil)
      .current
      .last
  end

  private

  def public_token_string
    Digest::UUID.uuid_v5(character.name, character.owner_hash)
  end
end
