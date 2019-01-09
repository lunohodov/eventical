class CharacterAccessToken
  attr_reader :character

  def initialize(character, esi: Eve::Esi)
    @character = character
    @esi = esi
  end

  def value
    character.token
  end

  def refresh!
    update_token(request_new_token)
    value
  end

  def refresh
    refresh! if expired?
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
    character.update!(
      token: new_token.token,
      token_expires_at: Time.at(new_token.expires_at).in_time_zone,
      refresh_token: new_token.refresh_token,
    )
  end

  def request_new_token
    esi.renew_access_token!(character.refresh_token)
  end
end
