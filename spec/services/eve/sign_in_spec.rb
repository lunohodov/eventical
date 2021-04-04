require "rails_helper"

describe Eve::SignIn, "#call" do
  it "creates a new character when no maching character found" do
    hash = auth_hash(
      "info" => {
        "name" => "Devas Weddo",
        "character_id" => 1,
        "character_owner_hash" => "0xME"
      }
    )

    character = Eve::SignIn.new(hash).call

    expect(character).to be_persisted
    expect(character.uid).to eq(1)
    expect(character.name).to eq("Devas Weddo")
    expect(character.owner_hash).to eq("0xME")
    expect(character.token).to eq(hash["credentials"]["token"])
    expect(character.token_expires_at.to_i).to eq(hash["credentials"]["expires_at"].to_i)
  end

  context "when a new account is created" do
    context "and successfuly saves" do
      it "notifies analytics of account created" do
        Eve::SignIn.new(auth_hash).call

        expect(analytics).to have_tracked("account.created").times(1)
      end
    end

    context "and fails to save" do
      it "does not notify analytics" do
        invalid_hash = auth_hash("info" => {"character_id" => nil})

        begin
          Eve::SignIn.new(invalid_hash).call
        rescue ActiveRecord::RecordInvalid
          # Pass
        end

        expect(analytics).not_to have_tracked("account.created")
      end
    end
  end

  context "with an existing character" do
    it "updates the character" do
      hash = auth_hash
      existing = create(:character, uid: hash["info"]["character_id"])

      expect(existing).to eq Eve::SignIn.new(hash).call
      expect(existing.reload.uid).to eq(hash["info"]["character_id"])
      expect(existing.reload.name).to eq(hash["info"]["name"])
      expect(existing.reload.owner_hash).to eq(hash["info"]["character_owner_hash"])
      expect(existing.reload.token).to eq(hash["credentials"]["token"])
      expect(existing.reload.token_expires_at.to_i).to eq(hash["credentials"]["expires_at"].to_i)
    end

    it "removes void, when refresh token voided" do
      hash = auth_hash
      existing = create(
        :character,
        :with_voided_refresh_token,
        uid: hash["info"]["character_id"]
      )

      expect { Eve::SignIn.new(hash).call }.to change { existing.reload.refresh_token_voided_at }.to(nil)
    end

    it "does not notify analytics" do
      hash = auth_hash
      create(:character, uid: hash["info"]["character_id"])

      Eve::SignIn.new(hash).call

      expect(analytics).not_to have_tracked("account.created")
    end
  end

  def auth_hash(options = {})
    build(:oauth_hash).merge(options)
  end
end
