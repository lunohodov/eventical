module Eve
  class SignIn
    delegate :errors, to: :character

    def initialize(auth_hash)
      @auth_hash = auth_hash
    end

    def call
      is_new_account = character.new_record?

      assign_character_attributes
      # TODO: Don't let ActiveRecord errors bubble up
      character.save!

      track_account_created if is_new_account

      character
    end

    private

    attr_accessor :auth_hash

    def character
      @character ||= Character.find_or_initialize_by(uid: character_uid)
    end

    def assign_character_attributes
      character.assign_attributes(
        name: character_name,
        owner_hash: character_owner_hash,
        refresh_token: refresh_token,
        refresh_token_voided_at: nil,
        token: token,
        token_expires_at: token_expiration_time,
        token_type: token_type,
        uid: character_uid
      )
    end

    def track_account_created
      Analytics.new.track_account_created(character)
    end

    def character_uid
      auth_hash.dig("info", "character_id")
    end

    def character_name
      auth_hash.dig("info", "name")
    end

    def character_owner_hash
      auth_hash.dig("info", "character_owner_hash")
    end

    def refresh_token
      auth_hash.dig("credentials", "refresh_token")
    end

    def token
      auth_hash.dig("credentials", "token")
    end

    def token_type
      auth_hash.dig("info", "token_type")
    end

    def token_expires
      auth_hash.dig("credentials", "token_expires")
    end

    def token_expiration_time
      Time.zone.at(auth_hash.dig("credentials", "expires_at"))
    end
  end
end
