ActiveSupport.on_load(:analytics) do
  # `self` refers to Analytics class. See `app/services/analytics.rb`
  self.backend = Staccato.tracker(ENV["ANALYTICS_KEY"] || "", nil, ssl: true) do |c| # rubocop:disable Metrics/LineLength
    if c.id.blank?
      require "staccato/adapter/logger"

      formatter = lambda { |params|
        "Analytics: " << params.map { |k, v| [k, v].join("=") }.join(" ")
      }

      c.add_adapter Staccato::Adapter::Logger.new(
        Staccato.ga_collection_uri,
        Rails.logger,
        formatter,
      )
    end
  end
end
