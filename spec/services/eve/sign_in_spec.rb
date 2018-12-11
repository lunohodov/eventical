require "rails_helper"

describe Eve::SignIn, "#call" do
  it "creates a new character when no maching character found" do
    hash = auth_hash(
      "info" => {
        "name" => "Devas Weddo",
        "character_id" => 1,
        "character_owner_hash" => "0xME",
      },
    )

    character = Eve::SignIn.new(hash).call

    expect(character).to be_persisted
    expect(character.uid).to eq(1)
    expect(character.name).to eq("Devas Weddo")
    expect(character.owner_hash).to eq("0xME")
    expect(character.token).to eq(hash["credentials"]["token"])
    expect(character.token_expires_at.to_i).to eq(
      hash["credentials"]["expires_at"].to_i,
    )
  end

  context "with an existing character" do
    it "updates the character" do
      hash = auth_hash
      existing = create(:character, uid: hash["info"]["character_id"])

      expect(existing).to eq Eve::SignIn.new(hash).call
      expect(existing.reload.uid).to eq(hash["info"]["character_id"])
      expect(existing.reload.name).to eq(hash["info"]["name"])
      expect(existing.reload.owner_hash).to eq(
        hash["info"]["character_owner_hash"],
      )
      expect(existing.reload.token).to eq(hash["credentials"]["token"])
      expect(existing.reload.token_expires_at.to_i).to eq(
        hash["credentials"]["expires_at"].to_i,
      )
    end
  end

  def auth_hash(options = {})
    build(:oauth_hash).merge(options)
  end
end
