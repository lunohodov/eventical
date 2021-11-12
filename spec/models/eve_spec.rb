require "rails_helper"

describe Eve do
  describe ".time_zone" do
    it "is UTC" do
      expect(Eve.time_zone).to eq ActiveSupport::TimeZone["UTC"]
    end
  end
end
