require "rails_helper"

describe Audit::Log, type: :model do
  describe "associations" do
    it { should belong_to(:auditable) }
    it { should belong_to(:character).optional(true) }
  end

  describe "validations" do
    it { should validate_presence_of(:action) }
  end
end
