require "rails_helper"

describe Eve::AccessToken, type: :model do
  describe "#expired?" do
    subject { described_class.new(character).expired? }

    let(:character) { instance_double(Character, token_expired?: true) }

    it { is_expected.to eq true }

    context "when not expired" do
      let(:character) { instance_double(Character, token_expired?: false) }

      it { is_expected.to eq false }
    end
  end

  describe "#renew!" do
    subject { described_class.new(character).renew! }

    let(:character) { create(:character, :with_expired_token) }
    let(:oauth_token) do
      stub_oauth_token(
        token: "new-token",
        expires_at: 1.day.from_now.midnight,
        refresh_token: "new-refresh-token"
      )
    end

    before do
      allow(oauth_token).to receive(:refresh!).and_return(oauth_token)
    end

    it "updates character's access token" do
      expect { subject }.to change { character.reload.token }.to("new-token")
    end

    it "updates character's refresh token" do
      expect { subject }.to change { character.reload.refresh_token }.to("new-refresh-token")
    end

    it "updates character's token expiration time" do
      expect { subject }
        .to change { character.reload.token_expires_at }.to(1.day.from_now.midnight)
    end

    context "with current token still valid" do
      let(:character) { create(:character) }

      it "does not update character's access token" do
        expect { subject }.not_to change { character.reload.token }
      end

      it "does not update character's refresh token" do
        expect { subject }.not_to change { character.reload.refresh_token }
      end

      it "does not update character's token expiration time" do
        expect { subject }.not_to change { character.reload.token_expires_at }
      end

      it "does not send requests to ESI" do
        expect(subject).to satisfy do
          expect(oauth_token).not_to have_received(:refresh!)
        end
      end
    end

    shared_examples "voids character's refresh token" do |error_code:|
      let(:oauth_error) { stubbed_oauth_error(error_code) }

      before do
        allow(oauth_token).to receive(:refresh!).and_raise(oauth_error)
      end

      it "voids character's refresh token" do
        begin
          subject
          fail("Error expected")
        rescue described_class::Error => _
          # Pass
        end

        expect(character).to be_refresh_token_voided
      end

      it "raises an error" do
        expect { subject }.to raise_error(described_class::Error, error_code.to_s)
      end
    end

    context "when esi responds with invalid token error" do
      it_behaves_like "voids character's refresh token", error_code: :invalid_token
    end

    context "when esi responds with invalid token error" do
      it_behaves_like "voids character's refresh token", error_code: :invalid_grant
    end
  end

  def stub_oauth_token(token:, refresh_token: nil, expires_at: nil)
    instance_spy(
      OAuth2::AccessToken,
      token: token || "token-abc",
      expires_at: expires_at || 1.day.from_now,
      refresh_token: refresh_token || "refresh-token-abc"
    ).tap do |stubbed_token|
      allow(OAuth2::AccessToken).to receive(:from_hash).and_return(stubbed_token)
    end
  end

  def stubbed_oauth_error(code)
    OAuth2::Error.allocate.tap do |e|
      e.instance_variable_set(:@code, code)
    end
  end
end
