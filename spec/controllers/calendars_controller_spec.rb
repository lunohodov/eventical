require "rails_helper"

describe CalendarsController, type: :controller do
  describe "#show" do
    it "renders the view" do
      character = create(:character)

      get :show, params: { character_id: character.id }

      expect(response).to render_template("show")
    end
  end
end
