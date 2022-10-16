class SignIn
  def initialize(auth_hash)
    @auth_hash = auth_hash
  end

  def save!
    Character.create_or_find_by!(uid: character_uid) do |character|
      character.assign_attributes(character_attributes)
    end.tap do |character|
      # An update will only take place if the record is dirty i.e
      # it is safe to call on newly created records.
      character.update!(character_attributes)
    end
  end

  private

  attr_reader :auth_hash

  def character_uid
    auth_hash.dig("info", "character_id")
  end

  def character_attributes
    {
      name: auth_hash.dig("info", "name"),
      owner_hash: auth_hash.dig("info", "character_owner_hash"),
      refresh_token: auth_hash.dig("credentials", "refresh_token"),
      refresh_token_voided_at: nil,
      token: auth_hash.dig("credentials", "token"),
      token_expires_at: Time.zone.at(auth_hash.dig("credentials", "expires_at")),
      token_type: auth_hash.dig("info", "token_type")
    }
  end
end
