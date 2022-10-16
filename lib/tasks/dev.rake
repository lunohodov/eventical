if Rails.env.development? || Rails.env.test?
  require "factory_bot"

  namespace :dev do
    desc "Sample data for local development environment"
    task prime: "db:setup" do
      include FactoryBot::Syntax::Methods

      create(:character)

      create(:character, :with_scopes).tap do |owner|
        create(:access_token, character: owner)
        create_events(owner)
      end
    end

    private

    def create_events(character)
      [
        ["[FLEET] Noobs on Patrol", 2.hours],
        ["Intro to D-Scanning and Safe Spots", 2.hours],
        ["Fleet Commanding 101", 1.day],
        ["Interceptors 101", 1.day],
        ["[FLEET] Noobs on Patrol", 2.days],
        ["[CORE] Introduction to Skills", 2.days],
        ["[FLEET] Noobs on Patrol", 3.days],
        ["Fleet Commanding 101", 3.days]
      ].each do |title, time_offset = data|
        create(
          :event,
          character: character,
          title: title,
          starts_at: time_offset.from_now
        )
      end
    end
  end
end
