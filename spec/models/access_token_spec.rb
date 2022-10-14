require "rails_helper"

describe AccessToken, type: :model do
  describe "associations" do
    it { should belong_to(:issuer) }
    it { should belong_to(:grantee).optional }
  end

  describe "validations" do
    it { validate_presence_of(:grantee) }
    it { validate_presence_of(:issuer) }
    it { validate_presence_of(:scope) }
    it { validate_presence_of(:character_owner_hash) }
  end

  describe "private scope" do
    it "returns records where issuer and grantee are the same" do
      issuer = create(:character)
      expected = create(:private_access_token, issuer: issuer)
      create(:access_token, issuer: issuer, grantee: nil)

      result = AccessToken.private.where(issuer: issuer)

      expect(result.count).to eq 1
      expect(result.first).to eq expected
    end
  end

  describe "current scope" do
    it "excludes already expired records" do
      create(:access_token, expires_at: 1.day.ago)

      expect(AccessToken.current.count).to eq(0)
    end

    it "excludes revoked records" do
      create(:access_token, revoked_at: 1.day.ago)

      expect(AccessToken.current.count).to eq(0)
    end

    it "includes yet to expire records" do
      create(:access_token, expires_at: Date.today)
      expected = create(:access_token, expires_at: Date.tomorrow)

      expect(AccessToken.current.count).to eq(1)
      expect(AccessToken.current.all).to match_array([expected])
    end
  end

  describe ".revoke!" do
    it "revokes given token" do
      access_token = create(:access_token)

      expect { AccessToken.revoke!(access_token) }
        .to change { access_token.reload.revoked? }
        .to(true)
    end

    it "revokes current tokens" do
      access_token = create(:private_access_token)
      create(:private_access_token, issuer: access_token.issuer)

      expect { AccessToken.revoke!(access_token) }
        .to change { AccessToken.where(revoked_at: nil).count }
        .to(0)
    end

    it "records revocation time" do
      access_token = create(:access_token)

      expect { AccessToken.revoke!(access_token) }
        .to change { access_token.reload.revoked_at }
        .from(nil)
    end

    it "raises an error when given token is not persisted" do
      access_token = build(:access_token)

      expect { AccessToken.revoke!(access_token) }
        .to raise_error(/persisted/)
    end
  end

  describe "#revoked?" do
    it "returns true, when revocation time present" do
      token = build(:access_token, revoked_at: Time.current)

      expect(token.revoked?).to eq(true)
    end

    it "returns false, when revocation time not present" do
      token = build(:access_token, revoked_at: nil)

      expect(token.revoked?).to eq(false)
    end
  end

  it "assigns character owner hash from issuer on create" do
    character = build_stubbed(:character, owner_hash: "abc")
    token = build(:private_access_token, issuer: character, character_owner_hash: nil)

    token.save!

    expect(token.character_owner_hash).to eq("abc")
  end

  it "does not overwrite character owner hash on update" do
    character = build_stubbed(:character, owner_hash: "initial")
    token = create(:private_access_token, issuer: character)

    token.update!(issuer: build_stubbed(:character, owner_hash: "abc"))

    expect(token.reload.character_owner_hash).to eq("initial")
  end
end
