ActiveSupport.on_load(:analytics) do
  # `self` refers to Analytics class. See `app/services/analytics.rb`
  self.backend = Staccato.tracker(ENV["ANALYTICS_KEY"] || "", nil, ssl: true)
end
