# frozen_string_literal: true

require "rails_helper"

describe Analytics::LocalBackend, type: :model do
  describe "#count" do
    it "increments counter" do
      resource = build_stubbed(:character)
      counter = create(:analytics_counter, value: 1, topic: "abc", owner: resource)
      backend = described_class.new

      expect { backend.count("abc", resource: resource) }
        .to change { counter.reload.value }.by(1)
    end

    context "when first time" do
      it "adds a new counter" do
        resource = build_stubbed(:character)
        backend = described_class.new

        backend.count("abc", resource: resource)
        counter = Analytics::Counter.find_by(topic: "abc", owner: resource)

        expect(counter).to be_present
        expect(counter.value).to eq 1
      end
    end
  end
end
