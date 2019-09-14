require "rails_helper"
require "securerandom"

describe CalendarFeedsController, type: :controller do
  include StubCurrentCharacterHelper

  describe "#show" do
    it "renders '404 Not Found', when no valid token found" do
      stub_current_character

      get :show, params: { id: SecureRandom.uuid }

      expect(response.body).to eq("404 Not Found")
    end

    it "notifies Sentry, when no valid token found" do
      stub_current_character
      bad_token = SecureRandom.uuid
      allow(Raven).to receive(:capture_exception)

      get :show, params: { id: bad_token }

      expect(Raven).to have_received(:capture_exception).with(
        an_instance_of(ActiveRecord::RecordNotFound),
        extra: controller.params.to_unsafe_h,
      )
    end
  end
end
