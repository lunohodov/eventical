class ApplicationJob < ActiveJob::Base
  def report_error(error)
    Sentry.capture_exception(
      error,
      extra: {job: self, arguments: arguments}
    )
  end
end
