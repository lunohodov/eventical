require "rails_helper"

RSpec.describe Analytics::Counter, type: :model do
  describe "validations" do
    it { should belong_to(:owner) }
    it { should validate_presence_of(:topic) }
    it { should validate_numericality_of(:value).only_integer.is_greater_than_or_equal_to(0) }
  end
end
