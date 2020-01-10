class EventSharing
  attr_reader :character

  def initialize(character)
    @character = character
  end

  def active?
    access_token.present?
  end

  def activate!
    unless active?
      @access_token = AccessToken.create!(
        issuer: character,
        grantee: nil,
        token: public_token_string,
      )
    end
  end

  def deactivate!
    if active?
      AccessToken.revoke!(access_token)
    end
  end

  def access_token
    @access_token ||= AccessToken.
      where(issuer: character, grantee: nil).
      current.
      last
  end

  private

  def public_token_string
    Digest::UUID.uuid_v5(character.name, character.owner_hash)
  end
end
