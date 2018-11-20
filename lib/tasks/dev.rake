if Rails.env.development? || Rails.env.test?
  require "factory_bot"

  namespace :dev do
    desc "Sample data for local development environment"
    task prime: "db:setup" do
      include FactoryBot::Syntax::Methods

      create(:character)
      create(:character, :with_scopes).tap do |character|
        create_list(:event, 10, character: character)
      end
    end
  end
end
