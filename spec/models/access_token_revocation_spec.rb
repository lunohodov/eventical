require "rails_helper"

describe AccessTokenRevocation do
  describe "#call" do
    it "revokes given access token" do
      access_token = create(:access_token)

      revocation = AccessTokenRevocation.new(access_token)

      expect { revocation.call }.
        to change { access_token.reload.revoked? }.
        from(false).
        to(true)
    end

    it "records revocation time" do
      access_token = create(:access_token)

      revocation = AccessTokenRevocation.new(access_token)

      expect { revocation.call }.
        to change { access_token.reload.revoked_at }.
        from(nil)
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

    it "raises an error when issuer is not present" do
      access_token = build(:access_token, :personal, issuer: nil)

      revocation = AccessTokenRevocation.new(access_token)

      expect { revocation.call }.
        to raise_error(ActiveModel::ValidationError, /issuer/i)
    end

    it "raises an error when grantee is not present" do
      access_token = build(:access_token, :personal, grantee: nil)

      revocation = AccessTokenRevocation.new(access_token)

      expect { revocation.call }.
        to raise_error(ActiveModel::ValidationError, /grantee/i)
    end
  end
end
