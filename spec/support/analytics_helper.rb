module AnalyticsHelper
  def analytics
    Analytics.backend
  end

  def stub_analytics
    instance_double(Analytics).tap do |analytics|
      allow(Analytics).to receive(:new).and_return(analytics)
    end
  end
end

RSpec.configure do |config|
  config.include AnalyticsHelper

  config.before do
    Analytics.backend = Analytics::InMemoryBackend.new
  end
end

RSpec::Matchers.define :have_tracked do |event|
  match do |backend|
    counters = backend.counters
      .find_all { |counter| counter.topic.to_s == event.to_s }
      .find_all { |counter| @resource.nil? || counter.owner == @resource }

    !counters.empty? && counters.all? { |counter| counter.value == (@times || 1) }
  end

  chain(:for_resource) { @resource = _1 }
  chain(:times) { @times = _1 }
end
