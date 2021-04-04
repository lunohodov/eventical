# frozen_string_literal: true

require "rails_helper"

describe Analytics::InMemoryBackend, type: :model do
  describe "#count" do
    # Not quite sure about this...
    it "stores counters in-memory" do
      backend = described_class.new

      backend.count("abc", resource: build_stubbed(:character))

      counter = backend.counters.last
      expect(counter).to be_readonly
    end

    it "increments counter" do
      resource = build_stubbed(:character)
      backend = described_class.new

      backend.count("abc", resource: resource)

      expect { backend.count("abc", resource: resource) }
        .to change { backend.counters.last.value }.by(1)
    end

    context "when first time" do
      it "adds a new counter" do
        resource = build_stubbed(:character)
        backend = described_class.new

        backend.count("abc", resource: resource)

        expect(backend).to have_counter("abc", resource: resource)
      end
    end
  end

  matcher :have_counter do |topic, resource:|
    match do |backend|
      counter = backend.counters.last
      counter.topic == topic && counter.owner == resource
    end
  end
end
