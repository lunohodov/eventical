require "securerandom"

FactoryBot.define do
  sequence :character_uid
  sequence :event_uid

  factory :event do
    character
    importance { nil }
    response { %w[attending declined tentative].sample }
    starts_at { Time.current }
    title { Faker::Name.name }
    uid { generate :event_uid }
  end

  factory :character do
    name { Faker::Name.name }
    owner_hash { Faker::Crypto.sha1 }
    refresh_token { Faker::Crypto.sha256 }
    scopes { nil }
    token { Faker::Crypto.sha1 }
    token_expires_at { Time.current }
    token_type { "Bearer" }
    uid { generate :character_uid }

    trait :with_scopes do
      scopes { "esi-calendar.read_calendar_events.v1" }
    end
  end
end
