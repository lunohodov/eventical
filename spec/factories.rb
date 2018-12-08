require "securerandom"

FactoryBot.define do
  factory :event do
    character
    importance { nil }
    response { %w[attending declined tentative].sample }
    starts_at { Time.current }
    title { Faker::Name.name }

    sequence(:uid)
  end

  factory :character do
    name { Faker::Name.name }
    owner_hash { Faker::Crypto.sha1 }
    refresh_token { Faker::Crypto.sha256 }
    scopes { nil }
    token { Faker::Crypto.sha1 }
    token_expires_at { Time.current }
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
          expires_at: character.token_expires_at,
        },
      )
    end
  end
end
