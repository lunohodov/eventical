require "rails_helper"

describe AccessToken, type: :model do
  describe "associations" do
    it { should belong_to(:issuer) }
    it { should belong_to(:grantee).optional }
  end

  describe "validations" do
    it { validate_presence_of :grantee }
    it { validate_presence_of :issuer }
    it { validate_presence_of :scope }

    describe "#event_owner_categories" do
      it { is_expected.to allow_value(nil).for(:event_owner_categories) }
      it { is_expected.to allow_value("").for(:event_owner_categories) }
      it { is_expected.to allow_value([]).for(:event_owner_categories) }
      it { is_expected.to allow_value("faction").for(:event_owner_categories) }
      it do
        is_expected.to allow_value(["faction"]).for(:event_owner_categories)
      end
      it do
        is_expected.to allow_value(%w[faction character])
          .for(:event_owner_categories)
      end
      it do
        is_expected.not_to allow_value(%w[faction something])
          .for(:event_owner_categories)
      end
    end
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

  describe ".revoke!" do
    it "revokes given token" do
      access_token = create(:access_token)

      expect { AccessToken.revoke!(access_token) }
        .to change { access_token.reload.revoked? }
        .to(true)
    end

    it "revokes current tokens" do
      access_token = create(:access_token, :personal)
      create(:access_token, :personal, issuer: access_token.issuer)

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

  describe ".by_slug!" do
    it "finds the token, when personal" do
      access_token = create(:access_token, :personal)

      found = AccessToken.by_slug!(access_token.slug)

      expect(found).to eq(access_token)
    end

    it "finds the token, when public" do
      access_token = create(:access_token, :public)

      found = AccessToken.by_slug!(access_token.slug)

      expect(found).to eq(access_token)
    end

    it "finds the last record when many" do
      access_token = create_list(:access_token, 2, token: "abc123").last

      found = AccessToken.by_slug!(access_token.slug)

      expect(found).to eq AccessToken.where(token: "abc123").last!
    end

    context "when token does not exist" do
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
