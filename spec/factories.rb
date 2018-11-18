require "securerandom"

FactoryBot.define do
  factory :character do
    name { Faker::Name.name }
    owner_hash { Faker::Crypto.sha1 }
    refresh_token { Faker::Crypto.sha256 }
    scopes { nil }
    token { Faker::Crypto.sha1 }
    token_expires_at { Time.current }
    token_type { "Bearer" }
    uid { SecureRandom.uuid }

    trait :with_scopes do
      scopes { "esi-calendar.read_calendar_events.v1" }
    end
  end
end
