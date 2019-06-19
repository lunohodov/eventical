require "ostruct"

module Eve
  module Esi
    class EventSource < SimpleDelegator
      def events
        super.map(&method(:map_event))
      end

      private

      def map_event(event)
        OpenStruct.new(
          uid: event.event_id,
          response: event.event_response,
          title: event.title,
          starts_at: event.event_date,
        ).freeze
      end
    end

    module ClassMethods
      def character_calendar(character)
        calendar = EveOnline::ESI::CharacterCalendar.new(
          token: character.token,
          character_id: character.uid,
        )
        EventSource.new(calendar)
      end

      # Renews the access token using the given refresh token
      def renew_access_token!(refresh_token, oauth_client: nil)
        oauth_client ||= build_oauth_client

        access_token = OAuth2::AccessToken.from_hash(
          oauth_client,
          refresh_token: refresh_token,
        )

        access_token.refresh!
      end

      private

      def oauth_client_options
        OmniAuth::Strategies::EveOnlineSso.default_options["client_options"]
      end

      def build_oauth_client
        OAuth2::Client.new(
          EVE_ONLINE_CLIENT_ID,
          EVE_ONLINE_SECRET_KEY,
          oauth_client_options,
        )
      end
    end

    extend ClassMethods
  end
end
