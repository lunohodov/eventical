class ApplicationJob < ActiveJob::Base
  def report_error(error)
    Raven.capture_exception(
      error,
      message: error.message,
      extra: { job: self },
    )
  end
end
