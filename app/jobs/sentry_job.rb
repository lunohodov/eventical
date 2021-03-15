class SentryJob < ApplicationJob
  queue_as :error

  retry_on(StandardError, wait: :exponentially_longer, attempts: 5) do |job, e|
    Rails.logger.error(
      "Error logging to Sentry: #{job.arguments.inspect}. Cause: #{e.message}"
    )
  end

  def perform(event)
    Raven.send_event(event)
  end
end
