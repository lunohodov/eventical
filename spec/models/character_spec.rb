require "rails_helper"

describe Character, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:token) }
    it { should validate_presence_of(:owner_hash) }
  end

  describe "#void_refresh_token!" do
    it "marks the refresh token voided" do
      character = create(:character)

      expect { character.void_refresh_token! }
        .to change { character.reload.refresh_token_voided_at }.from(nil)
    end
  end

  describe "refresh_token_voided?" do
    it "is true, when refresh token has been voided" do
      character = build(:character, refresh_token_voided_at: Time.current)

      expect(character.refresh_token_voided?).to be_truthy
    end

    it "is false, when refresh token has not been voided" do
      character = build(:character, refresh_token_voided_at: nil)

      expect(character.refresh_token_voided?).to be_falsey
    end
  end

  describe "#token_expires_at?" do
    it "is true, when expiration time is before given time" do
      c = build(:character, token_expires_at: Time.current)

      expect(c.token_expires_at?(1.second.from_now)).to eq(true)
    end

    it "is true, when expiration time equals given time" do
      c = build(:character, token_expires_at: Time.current)

      expect(c.token_expires_at?(c.token_expires_at)).to eq(true)
    end

    it "is false, when expiration time is after given time" do
      c = build(:character, token_expires_at: 1.second.ago)

      expect(c.token_expires_at?(Time.current)).to eq(true)
    end
  end

  describe "#token_expired?" do
    it "is true, when expiration time is not present" do
      c = build(:character, token_expires_at: nil)

      expect(c.token_expired?).to eq(true)
    end

    it "is true, when expiration time is in the past" do
      c = build(:character, token_expires_at: 1.day.ago)

      expect(c.token_expired?).to eq(true)
    end

    it "is false, when expiration time is in the future" do
      c = build(:character, token_expires_at: Date.tomorrow)

      expect(c.token_expired?).to eq(false)
    end
  end
end
