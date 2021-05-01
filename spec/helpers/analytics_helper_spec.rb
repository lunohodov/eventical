require "rails_helper"

describe AnalyticsHelper, type: :helper do
  describe "#can_use_analytics?" do
    subject { helper.can_use_analytics? }

    it "returns true" do
      ClimateControl.modify PLAUSIBLE_ENABLED: "true" do
        expect(subject).to be_truthy
      end
    end

    context "with arbitrary ENV variable value" do
      it "returns false" do
        ClimateControl.modify PLAUSIBLE_ENABLED: "1" do
          expect(subject).to be_falsey
        end
      end
    end

    context "without ENV variable" do
      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end
end
