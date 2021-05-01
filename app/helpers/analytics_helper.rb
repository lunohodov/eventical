module AnalyticsHelper
  def can_use_analytics?
    ENV["PLAUSIBLE_ENABLED"] == "true"
  end

  def can_use_fathom_analytics?
    fathom_site_token.present?
  end

  def fathom_site_token
    ENV["FATHOM_SITE"]
  end
end
