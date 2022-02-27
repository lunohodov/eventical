require "rails_helper"

describe SessionsController, type: :controller do
  before { ActiveJob::Base.queue_adapter = :test }

  describe "#create" do
    subject { post :create, params: {provider: "eve_online_sso"} }

    it "redirects to calendar" do
      stub_oauth_request

      expect(subject).to redirect_to private_access_path
    end

    it "tracks character's login" do
      stub_oauth_request

      expect(subject).to satisfy do
        expect(analytics).to have_tracked("character.logged_in").times(1)
      end
    end

    it "does not redirect to an outside OAuth origin" do
      stub_oauth_request(origin: "//google.com")

      expect(subject).to redirect_to(private_access_path)
    end

    it "pulls upcoming events" do
      stub_oauth_request

      expect { subject }.to have_enqueued_job(PullEventsJob)
    end

    context "when existing account signs in" do
      it "does not pull upcoming events" do
        character = create(:character, created_at: 1.day.ago)
        stub_oauth_request(build(:oauth_hash, uid: character.uid))

        expect { subject }.not_to have_enqueued_job(PullEventsJob)
      end
    end
  end

  context "#destroy" do
    before { stub_current_character }

    it "resets the current session" do
      allow(controller).to receive(:reset_session)

      get(:destroy)

      expect(controller).to have_received(:reset_session)
    end

    it "logs the current character out" do
      get(:destroy)

      expect(analytics).to have_tracked("character.logged_out")
    end
  end

  def stub_oauth_request(auth_hash = nil, origin: nil)
    request.env["omniauth.auth"] = stub_oauth_hash(auth_hash)
    request.env["omniauth.origin"] = origin
  end
end
