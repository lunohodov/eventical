module Eve
  class RenewAccessToken
    delegate :errors, to: :character

    attr_reader :character

    def initialize(character, force: true)
      @character = character
      @force = force
    end

    def forced?
      @force == true
    end

    def call
      if character.token_expired? || forced?
        update_character_attributes(refresh_access_token)
        character.save
      else
        true
      end
    end

    private

    def update_character_attributes(access_token)
      character.assign_attributes(
        token: access_token.token,
        token_expires_at: Time.at(access_token.expires_at).in_time_zone,
        refresh_token: access_token.refresh_token,
      )
    end

    def refresh_access_token
      OAuth2::AccessToken.from_hash(
        oauth_client,
        refresh_token: character.refresh_token,
      ).refresh!
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(
        EVE_ONLINE_CLIENT_ID,
        EVE_ONLINE_SECRET_KEY,
        oauth_client_options,
      )
    end

    def oauth_client_options
      OmniAuth::Strategies::EveOnlineSso.default_options["client_options"]
    end
  end
end
