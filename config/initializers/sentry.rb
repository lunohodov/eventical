Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger]
  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]
  config.release = "eventical@#{Eventical.release_version}"

  config.traces_sampler = lambda do |sampling_context|
    unless sampling_context[:parent_sampled].nil?
      next sampling_context[:parent_sampled]
    end

    transaction_context = sampling_context[:transaction_context]

    op = transaction_context[:op]
    transaction_name = transaction_context[:name]

    case op
    when /request/
      if /calendars/.match?(transaction_name)
        0.5
      else
        0
      end
    when /active_job/
      0.25
    else
      0.0
    end
  end
end
