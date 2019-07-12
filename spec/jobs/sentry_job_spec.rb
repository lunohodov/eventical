require "rails_helper"

describe SentryJob, type: :job do
  it "sends given event to Sentry" do
    allow(Raven).to receive(:send_event)

    SentryJob.perform_now(ok: false)

    expect(Raven).to have_received(:send_event).with(ok: false)
  end
end
