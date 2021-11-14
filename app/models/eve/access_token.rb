# frozen_string_literal: true

module Eve
  class AccessToken
    class Error < ::StandardError
    end

    attr_reader :character

    delegate :logger, to: Rails

    def initialize(character)
      @character = character
    end

    def expired?
      character.token_expired?
    end

    def void!
      logger.info "Voiding ESI refresh token for character #{character.name}"
      character.void_refresh_token!
    end

    def renew!
      if expired?
        logger.info "Refreshing ESI token for character #{character.name}"

        renewed_token = oauth_access_token.refresh!

        character.update!(
          token: renewed_token.token,
          token_expires_at: Time.zone.at(renewed_token.expires_at),
          refresh_token: renewed_token.refresh_token
        )
      end
    rescue OAuth2::Error => e
      if /invalid_token/.match?(e.code)
        void!
      end

      raise self.class::Error, e.code, cause: e
    end

    private

    def oauth_access_token
      OAuth2::AccessToken.from_hash(
        oauth_client,
        refresh_token: character.refresh_token,
        expires_at: character.token_expires_at
      )
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(
        EVE_ONLINE_CLIENT_ID,
        EVE_ONLINE_SECRET_KEY,
        oauth_client_options
      )
    end

    def oauth_client_options
      OmniAuth::Strategies::EveOnlineSso.default_options["client_options"].to_hash.symbolize_keys
    end
  end
end
