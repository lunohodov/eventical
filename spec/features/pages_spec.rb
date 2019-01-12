require "rails_helper"

feature "Static pages", type: :feature do
  [
    "/",
    "/about",
  ].each do |page_path|
    scenario "able to visit #{page_path}" do
      visit page_path

      expect(current_path).to eq(page_path)
    end
  end
end
