require "rails_helper"

RSpec.describe SignIn, type: :model do
  it "does not create a new record" do
    character = create(:character)
    auth_hash = build(:oauth_hash, uid: character.uid)
    sign_in = described_class.new(auth_hash)

    expect { sign_in.save! }.not_to change { Character.count }
  end

  it "updates character's name" do
    character = create(:character, name: "Oldman Gary")
    auth_hash = build(:oauth_hash, uid: character.uid, character_name: "Newman Paul")

    described_class.new(auth_hash).save!

    expect(character.reload.name).to eq "Newman Paul"
  end

  it "updates character's owner hash" do
    character = create(:character, owner_hash: "old")
    auth_hash = build(:oauth_hash, uid: character.uid, character_owner_hash: "new")

    described_class.new(auth_hash).save!

    expect(character.reload.owner_hash).to eq "new"
  end

  it "updates character's refresh token" do
    character = create(:character, refresh_token: "old")
    auth_hash = build(:oauth_hash, uid: character.uid, refresh_token: "new")

    described_class.new(auth_hash).save!

    expect(character.reload.refresh_token).to eq "new"
  end

  it "updates character's token expiration time" do
    character = create(:character, token_expires_at: Time.current)
    auth_hash = build(:oauth_hash, uid: character.uid, token_expires_at: Time.new(2000))

    described_class.new(auth_hash).save!

    expect(character.reload.token_expires_at).to eq Time.new(2000)
  end

  it "updates character's token" do
    character = create(:character, token: "old")
    auth_hash = build(:oauth_hash, uid: character.uid, token: "new")

    described_class.new(auth_hash).save!

    expect(character.reload.token).to eq "new"
  end

  it "removes refresh token's void flag" do
    character = create(:character, :with_voided_refresh_token)
    auth_hash = build(:oauth_hash, uid: character.uid)

    described_class.new(auth_hash).save!

    expect(character.reload.refresh_token_voided?).to be_falsey
  end

  context "without existing character record" do
    it "creates a new record" do
      auth_hash = build(:oauth_hash)
      sign_in = described_class.new(auth_hash)

      expect { sign_in.save! }.to change { Character.count }.by(1)
    end

    it "saves character's name" do
      auth_hash = build(:oauth_hash, character_name: "Abc")

      character = described_class.new(auth_hash).save!

      expect(character.name).to eq "Abc"
    end

    it "saves character's owner hash" do
      auth_hash = build(:oauth_hash, character_owner_hash: "abc-hash")

      character = described_class.new(auth_hash).save!

      expect(character.owner_hash).to eq "abc-hash"
    end

    it "saves character's refresh token" do
      auth_hash = build(:oauth_hash, refresh_token: "abc-refresh")

      character = described_class.new(auth_hash).save!

      expect(character.refresh_token).to eq "abc-refresh"
    end

    it "saves character's token expiration time" do
      auth_hash = build(:oauth_hash, token_expires_at: Time.new(2000))

      character = described_class.new(auth_hash).save!

      expect(character.token_expires_at).to eq Time.new(2000)
    end

    it "saves character's token" do
      auth_hash = build(:oauth_hash, token: "abc-token")

      character = described_class.new(auth_hash).save!

      expect(character.token).to eq "abc-token"
    end

    it "saves character's uid" do
      auth_hash = build(:oauth_hash, uid: 1)

      character = described_class.new(auth_hash).save!

      expect(character.uid).to eq 1
    end
  end
end
