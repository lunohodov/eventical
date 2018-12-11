require "rails_helper"

describe "pages/index.html.erb" do
  context "when user is signed in" do
    before do
      controller.class.include Authenticating
    end

    it "renders link to calendar page" do
      allow(controller).to receive(:signed_in?).and_return(true)

      render

      expect(rendered).to have_link(href: calendar_url)
      expect(rendered).not_to have_link(href: login_url)
    end
  end
end
