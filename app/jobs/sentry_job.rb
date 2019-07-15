class SentryJob < ApplicationJob
  queue_as :error

  def perform(event)
    Raven.send_event(event)
  end
end
