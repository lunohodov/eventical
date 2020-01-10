require "rails_helper"

describe AccessTokenRevocation do
  describe "#call" do
    it "revokes given access token" do
      access_token = create(:access_token)
      allow(AccessToken).to receive(:revoke!).with(access_token)

      AccessTokenRevocation.new(access_token).call

      expect(AccessToken).to have_received(:revoke!).once
    end

    it "creates a new access token" do
      access_token = create(:access_token)

      expect { AccessTokenRevocation.new(access_token).call }.
        to change { AccessToken.count }.
        by(1)
    end

    it "returns a valid access token" do
      access_token = create(:access_token)

      result = AccessTokenRevocation.new(access_token).call

      expect(result.issuer).to eq(access_token.issuer)
      expect(result.grantee).to eq(access_token.grantee)
      expect(result.revoked?).to eq(false)
    end
  end
end
