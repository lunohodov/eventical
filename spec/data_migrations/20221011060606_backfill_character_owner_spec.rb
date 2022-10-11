require "rails_helper"

RSpec.describe "20221011060606_backfill_character_owner", type: :data_migration do
  it "assigns character owner hash to an access token" do
    characters = [
      create(:character, owner_hash: "abc"),
      create(:character, owner_hash: "def")
    ]
    token1 = create(:private_access_token, issuer: characters.first, character_owner_hash: nil)
    token2 = create(:private_access_token, issuer: characters.second, character_owner_hash: nil)

    run_data_migration

    expect(token1.reload.character_owner_hash).to eq("abc")
    expect(token2.reload.character_owner_hash).to eq("def")
  end

  it "is idempotent for access tokens" do
    character = create(:character, owner_hash: "abc")
    access_token = create(:private_access_token, issuer: character, character_owner_hash: "existing")

    expect { run_data_migration }.not_to change { access_token.reload.character_owner_hash }.from("existing")
  end

  it "assigns character owner hash to an event" do
    characters = [
      create(:character, owner_hash: "abc"),
      create(:character, owner_hash: "def")
    ]
    event1 = create(:event, character: characters.first, character_owner_hash: nil)
    event2 = create(:event, character: characters.second, character_owner_hash: nil)

    run_data_migration

    expect(event1.reload.character_owner_hash).to eq("abc")
    expect(event2.reload.character_owner_hash).to eq("def")
  end

  it "is idempotent for events" do
    character = create(:character, owner_hash: "abc")
    event = create(:event, character: character, character_owner_hash: "existing")

    expect { run_data_migration }.not_to change { event.reload.character_owner_hash }.from("existing")
  end
end
