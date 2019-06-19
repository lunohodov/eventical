require "rails_helper"

describe Eve do
  xdescribe ".character_calendar" do
    it "returns an event source" do
      character = build(:character)

      result = Eve.character_calendar(character)

      expect(result).to respond_to(:events)
    end
  end
end
