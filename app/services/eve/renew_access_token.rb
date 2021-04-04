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
      update_character(refresh_access_token) if should_renew?
    rescue OAuth2::Error => e
      # We are only interested in:
      #   - 'invalid_token' - token expired, revoked or character owner changed
      # Other errors include:
      #   - 'invalid_request' - token may be malformed
      #   - 'invalid_client', 'invalid_grant', 'unsupported_grant_type',
      #     'invalid_scope'
      if /invalid_token/.match?(e.code)
        character.void_refresh_token!
        track_refresh_token_voided
      end
      raise
    end

    private

    def track_refresh_token_voided
      Analytics.new.track_refresh_token_voided(character)
    end

    def should_renew?
      character.token_expired? || forced?
    end

    def update_character(access_token)
      character.update!(
        token: access_token.token,
        token_expires_at: Time.at(access_token.expires_at).in_time_zone,
        refresh_token: access_token.refresh_token
      )
    end

    def refresh_access_token
      OAuth2::AccessToken.from_hash(
        oauth_client,
        refresh_token: character.refresh_token
      ).refresh!
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(
        EVE_ONLINE_CLIENT_ID,
        EVE_ONLINE_SECRET_KEY,
        oauth_client_options
      )
    end

    def oauth_client_options
      OmniAuth::Strategies::EveOnlineSso.default_options["client_options"]
    end
  end
end
