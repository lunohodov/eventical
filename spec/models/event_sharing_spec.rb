require "rails_helper"

describe EventSharing, type: :model do
  it "is active, when an associated access token exists" do
    create(:access_token, issuer: character, grantee: nil)
    es = EventSharing.new(character)

    expect(es).to be_active
  end

  it "is not active, without an associated access token" do
    es = EventSharing.new(character)

    expect(es).not_to be_active
  end

  it "is not active, when the associated access token is expired" do
    create(:access_token, issuer: character, grantee: nil, expires_at: 1.minute.ago)
    es = EventSharing.new(character)

    expect(es).not_to be_active
  end

  describe "#activate!" do
    it "creates an associated public access token" do
      es = EventSharing.new(character)

      expect { es.activate! }.to change {
        AccessToken
          .where(issuer: character, grantee: nil)
          .current
          .count
      }.from(0).to(1)
    end
  end

  describe "#deactivate!" do
    it "revokes the associated access token" do
      access_token = create(:access_token, issuer: character, grantee: nil)
      es = EventSharing.new(character)

      expect { es.deactivate! }
        .to change { access_token.reload.revoked? }
        .to(true)
    end
  end

  def character
    @character ||= create(:character)
  end
end
