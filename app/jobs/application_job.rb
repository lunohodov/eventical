class ApplicationJob < ActiveJob::Base
  delegate :logger, to: Rails

  def analytics
    Analytics.new
  end
end
