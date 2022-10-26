require "rails_helper"

describe AccessToken, type: :model do
  describe "associations" do
    it { should belong_to(:character) }
  end

  describe "validations" do
    it { validate_presence_of(:character) }
  end

  describe "current scope" do
    it "excludes revoked records" do
      create(:access_token, revoked_at: 1.day.ago)

      expect(AccessToken.current.count).to eq(0)
    end

    it "includes non revoked records" do
      create(:access_token, revoked_at: Time.current)
      expected = create(:access_token, revoked_at: nil)

      expect(AccessToken.current.count).to eq(1)
      expect(AccessToken.current.all).to match_array([expected])
    end
  end

  describe ".for" do
    it "returns the last current token" do
      character = create(:character)
      create_list(:access_token, 2, character: character)
      create(:access_token)

      token = AccessToken.for(character)

      expect(token).to eq(AccessToken.where(character: character).last)
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
      access_token = create(:access_token)
      create(:access_token, character: access_token.character)

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
end
