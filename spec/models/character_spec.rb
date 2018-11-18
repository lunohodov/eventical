require "rails_helper"

describe Character, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:token) }
    it { should validate_presence_of(:refresh_token) }
    it { should validate_presence_of(:owner_hash) }
  end

  describe "#token_expired?" do
    it "is true, when expiration time is in the past" do
      c = create(:character, token_expires_at: 1.day.ago)

      expect(c.token_expired?).to eq(true)
    end

    it "is false, when expiration time is in the future" do
      c = create(:character, token_expires_at: Date.tomorrow)

      expect(c.token_expired?).to eq(false)
    end
  end
end
