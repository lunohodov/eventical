require "securerandom"
require "ostruct"

FactoryBot.define do
  factory :audit_log, class: "Audit::Log" do
  end

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
    importance { 1 }
    title { "Event #{event_id}" }
  end

  factory :event do
    sequence(:uid)

    character
    importance { 1 }
    response { "attending" }
    starts_at { rand(2..7).days.from_now }
    title { Faker::Name.name }
  end

  factory :character do
    name { Faker::Name.name }
    owner_hash { Faker::Crypto.sha1 }
    refresh_token { Faker::Crypto.sha256 }
    refresh_token_voided_at { nil }
    token { Faker::Crypto.sha1 }
    token_expires_at { 1.day.from_now }

    sequence(:uid)

    trait :with_expired_token do
      token_expires_at { 1.day.ago }
    end

    trait :with_voided_refresh_token do
      refresh_token_voided_at { 1.minute.ago }
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
    character
    token { nil }
    revoked_at { nil }
  end
end
