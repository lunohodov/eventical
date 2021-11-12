require "securerandom"
require "ostruct"

FactoryBot.define do
  factory :eve_access_token, class: "Eve::AccessToken" do
  end

  factory :analytics_counter, class: "Analytics::Counter" do
    association :owner, factory: :character

    topic { "login" }
    value { 1 }
  end

  factory :setting do
    owner_hash { SecureRandom.uuid }
    time_zone { "Europe/Amsterdam" }
  end

  factory :esi_event, class: "OpenStruct" do
    skip_create

    sequence(:event_id)

    event_date { rand(4).day.from_now }
    event_response { "attending" }
    title { "Event #{event_id}" }
  end

  factory :esi_event_details, class: "OpenStruct" do
    skip_create

    sequence(:event_id)

    date { rand(4).day.from_now }
    duration { 1.hour.to_i }
    event_response { "attending" }
    importance { nil }
    owner_type { "character" }
    owner_id { 123_456 }
    owner_name { "Devas Weddo" }
    text { "Minins ops with the casual Atron." }
    title { "Mining ops in Hevris" }
  end

  factory :event do
    sequence(:uid)

    character
    details_updated_at { created_at }
    importance { nil }
    owner_category { "character" }
    owner_name { character.name }
    owner_uid { character.uid }
    response { "attending" }
    starts_at { rand(2..7).days.from_now }
    title { Faker::Name.name }

    trait :without_details do
      details_updated_at { nil }
      owner_category { nil }
      owner_name { nil }
      owner_uid { nil }
    end

    trait :public do
      title { "[PUBLIC] #{Faker::Name.name}" }
    end

    trait :corporate do
      owner_category { "corporation" }
      owner_name { "#{character.name} Corporation" }
      owner_uid { character.uid * 10 }
    end

    trait :alliance do
      owner_category { "alliance" }
      owner_name { "#{character.name} Alliance" }
      owner_uid { character.uid * 100 }
    end

    trait :faction do
      owner_category { "faction" }
      owner_name { "Gallente Federation" }
      owner_uid { character.uid * 1000 }
    end

    trait :ccp do
      owner_category { "eve_server" }
      owner_name { "CCP" }
      owner_uid { character.uid * 10_000 }
    end
  end

  factory :character do
    name { Faker::Name.name }
    owner_hash { Faker::Crypto.sha1 }
    refresh_token { Faker::Crypto.sha256 }
    refresh_token_voided_at { nil }
    scopes { nil }
    token { Faker::Crypto.sha1 }
    token_expires_at { 1.day.from_now }
    token_type { "Bearer" }

    sequence(:uid)

    trait :with_expired_token do
      token_expires_at { 1.day.ago }
    end

    trait :with_voided_refresh_token do
      refresh_token_voided_at { 1.minute.ago }
    end

    trait :with_scopes do
      scopes { "esi-calendar.read_calendar_events.v1" }
    end
  end

  factory :oauth_hash, class: "OmniAuth::AuthHash" do
    skip_create

    transient do
      uid { 1 }
      character_name { "Good Character" }
      character_owner_hash { SecureRandom.uuid }
      character_token_type { "Bearer" }
      refresh_token { SecureRandom.uuid }
      token { SecureRandom.uuid }
      token_expires_at { 20.minutes.from_now }
    end

    initialize_with do
      new(
        provider: "eve_online_sso",
        uid: uid,
        info: {
          character_id: uid,
          character_owner_hash: character_owner_hash,
          name: character_name,
          token_type: character_token_type
        },
        credentials: {
          token: token,
          refresh_token: refresh_token,
          expires_at: token_expires_at
        }
      )
    end
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

    trait :public do
      issuer { create(:character) }
      grantee { nil }
    end
  end
end
