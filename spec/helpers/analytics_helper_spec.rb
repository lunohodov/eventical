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

  describe "#can_use_fathom_analytics?" do
    subject { helper.can_use_fathom_analytics? }

    it "returns true when a Fathom site is configured" do
      ClimateControl.modify FATHOM_SITE: "abc" do
        expect(subject).to be_truthy
      end
    end

    context "without configured Fathom site" do
      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end
end
