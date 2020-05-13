require "rails_helper"

describe AnalyticsHelper, type: :helper do
  describe "#can_use_analytics?" do
    it "returns true when a Fathom site is configured" do
      ClimateControl.modify FATHOM_SITE: "abc" do
        expect(helper.can_use_analytics?).to be_truthy
      end
    end

    context "without configured Fathom site" do
      it "returns false" do
        expect(helper.can_use_analytics?).to be_falsey
      end
    end
  end
end
