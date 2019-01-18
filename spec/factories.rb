require "securerandom"
require "ostruct"

EVENT_RESPONSES = %w[attending declined tentative].freeze

FactoryBot.define do
  factory :esi_event, class: "OpenStruct" do
    skip_create

    sequence(:event_id)

    title { "Event #{event_id}" }
    event_date { Time.current }
    event_response { EVENT_RESPONSES.sample }
  end

  factory :event do
    sequence(:uid)

    character
    importance { nil }
    response { EVENT_RESPONSES.sample }
    starts_at { rand(4).day.from_now }
    title { Faker::Name.name }
  end

  factory :agenda, class: "Agenda" do
    skip_create

    events { create_list(:event, 2) }

    initialize_with do
      new(events: events)
    end
  end

  factory :character do
    name { Faker::Name.name }
    owner_hash { Faker::Crypto.sha1 }
    refresh_token { Faker::Crypto.sha256 }
    scopes { nil }
    token { Faker::Crypto.sha1 }
    token_expires_at { 1.day.from_now }
    token_type { "Bearer" }

    sequence(:uid)

    trait :with_scopes do
      scopes { "esi-calendar.read_calendar_events.v1" }
    end
  end

  factory :oauth_hash, class: "OmniAuth::AuthHash" do
    skip_create

    transient do
      character { build(:character) }
    end

    initialize_with do
      new(
        provider: "eve_online_sso",
        uid: character.uid,
        info: {
          character_id: character.uid,
          character_owner_hash: character.owner_hash,
          name: character.name,
          token_type: character.token_type,
        },
        credentials: {
          token: character.token,
          refresh_token: character.refresh_token,
          expires_at: character.token_expires_at,
        },
      )
    end
  end

  factory :calendar, class: "Calendar" do
    initialize_with { new(time_zone: time_zone) }
  end

  factory :access_token do
    issuer { create(:character) }
    grantee { create(:character) }
    token { nil }
    expires_at { 1.month.from_now }
    revoked_at { nil }

    trait :personal do
      issuer { create(:character) }
      grantee { issuer }
    end
  end
end
