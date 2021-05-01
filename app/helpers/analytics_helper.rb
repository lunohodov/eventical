module AnalyticsHelper
  def can_use_analytics?
    ENV["PLAUSIBLE_ENABLED"] == "true"
  end
end
