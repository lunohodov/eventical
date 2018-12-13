class CharacterAccessToken
  attr_reader :character

  def initialize(character, esi: Eve::Esi)
    @character = character
    @esi = esi
  end

  def refresh!
    request_new_token.tap do |new_token|
      update_token(new_token)
    end
  end

  def expires_at?(time)
    character.token_expires_at?(time)
  end

  def expired?
    character.token_expired?
  end

  private

  attr_reader :esi

  def update_token(new_token)
    character.update!(token: new_token)
  end

  def request_new_token
    esi.renew_access_token!(character.refresh_token)
  end
end
