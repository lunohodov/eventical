require "rails_helper"

describe AccessToken, type: :model do
  describe "validations" do
    it { validate_presence_of :grantee }
    it { validate_presence_of :issuer }
  end

  describe "personal scope" do
    it "returns where issuer is the grantee" do
      issuer = create(:character)
      create(:access_token, issuer: issuer)
      personal_token = create(:access_token, issuer: issuer, grantee: issuer)

      expect(AccessToken.personal(issuer).count).to eq(1)
      expect(AccessToken.personal(issuer).all).to eq([personal_token])
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

  describe ".by_slug!" do
    it "returns found token" do
      access_token = create(:access_token)

      found = AccessToken.by_slug!(access_token.token)

      expect(found).to eq(access_token)
      expect(found).not_to be_revoked
      expect(found).not_to be_expired
    end

    context "when not found" do
      it "raises an error" do
        expect do
          AccessToken.by_slug!("non-existing")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
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

  describe "#personal?" do
    it "returns true, when grantee is the issuer" do
      issuer = Character.new(id: 1)

      token = build(:access_token, issuer: issuer, grantee: issuer)

      expect(token.personal?).to eq(true)
    end

    it "returns false, when grantee is not issuer" do
      issuer = Character.new(id: 1)
      grantee = Character.new(id: 2)

      token = build(:access_token, issuer: issuer, grantee: grantee)

      expect(token.personal?).to eq(false)
    end
  end

  describe "#expired?" do
    it "returns true, when expiration time is in the past" do
      token = build(:access_token, expires_at: 1.minute.ago)

      expect(token.expired?).to eq(true)
    end

    it "returns false, when expiration time is in the future" do
      token = build(:access_token, expires_at: Date.tomorrow)

      expect(token.expired?).to eq(false)
    end

    it "returns false, when expiration time is not specified" do
      token = build(:access_token, expires_at: nil)

      expect(token.expired?).to eq(false)
    end
  end
end
