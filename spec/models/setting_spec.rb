require "rails_helper"

describe Setting, type: :model do
  it "allows to be persisted, when pristine" do
    owner_hash = build(:character).owner_hash

    expect(Setting.create(owner_hash: owner_hash)).to be_persisted
  end

  describe ".for_character" do
    it "returns the corresponding settings" do
      character = create(:character)
      expected = create(:setting, owner_hash: character.owner_hash)

      expect(Setting.for_character(character)).to eq expected
    end
  end

  describe "#time_zone" do
    it "defaults to EVE Online time zone" do
      setting = Setting.new

      expect(setting.time_zone).to eq Eve.time_zone
    end

    it "accepts a string value" do
      setting = build(:setting, time_zone: "Sofia")

      expect(setting.time_zone).to eq ActiveSupport::TimeZone["Sofia"]
    end

    it "accepts a TimeZone value" do
      setting = build(:setting, time_zone: ActiveSupport::TimeZone["Sofia"])

      expect(setting.time_zone).to eq ActiveSupport::TimeZone["Sofia"]
    end

    it "accepts a nil value" do
      setting = build(:setting, time_zone: nil)

      expect(setting.time_zone).to be_nil
    end
  end
end
