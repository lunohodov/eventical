class ApplicationJob < ActiveJob::Base
  delegate :logger, to: Rails

  def report_error(error)
    Sentry.capture_exception(
      error,
      extra: {job: self, arguments: arguments}
    )
  end

  def analytics
    Analytics.new
  end
end
