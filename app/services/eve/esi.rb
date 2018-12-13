module Eve
  module Esi
    include ActiveSupport::Configurable

    module ClassMethods
      # Renews the access token using the given refresh token
      def renew_access_token!(refresh_token, oauth_client: nil)
        oauth_client ||= build_oauth_client

        access_token = OAuth2::AccessToken.from_hash(
          oauth_client,
          refresh_token: refresh_token,
        )

        new_token = access_token.refresh!

        new_token.token
      end

      private

      def oauth_client_options
        OmniAuth::Strategies::EveOnlineSso.default_options["client_options"]
      end

      def build_oauth_client
        OAuth2::Client.new(
          config.client_id,
          config.client_secret,
          oauth_client_options,
        )
      end
    end

    extend ClassMethods
  end
end
