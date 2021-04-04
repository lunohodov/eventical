ActiveSupport.on_load(:analytics) do
  # `self` refers to Analytics class. See `app/services/analytics.rb`
  self.backend = ::Analytics::LocalBackend.new
end
