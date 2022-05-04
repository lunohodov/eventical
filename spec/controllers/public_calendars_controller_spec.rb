require "rails_helper"

describe PublicCalendarsController, type: :controller do
  include StubCurrentCharacterHelper

  describe "#show" do
    it "renders the view" do
      stub_current_character

      get :show

      expect(response).to render_template("show")
    end
  end
end
