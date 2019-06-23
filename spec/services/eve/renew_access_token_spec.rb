require "rails_helper"
require "securerandom"

describe Eve::RenewAccessToken do
  it "is forced by default" do
    character = build(:character)

    expect(Eve::RenewAccessToken.new(character).forced?).to eq true
  end

  it "is forced, when specified" do
    character = build(:character)

    expect(Eve::RenewAccessToken.new(character, force: true).forced?).
      to eq true
  end

  it "is not forced, when specified" do
    character = build(:character)

    expect(Eve::RenewAccessToken.new(character, force: false).forced?).
      to eq false
  end

  describe "#call" do
    it "updates character's access token" do
      character = create(:character, token: "old")

      stub_oauth_token(token: "new")

      expect { Eve::RenewAccessToken.new(character).call }.
        to change { character.reload.token }.
        from("old").
        to("new")
    end

    it "updates character's access token expiration time" do
      character = create(:character, token_expires_at: Time.utc(2000))

      stub_oauth_token(expires_at: Time.utc(3000))

      expect { Eve::RenewAccessToken.new(character).call }.
        to change { character.reload.token_expires_at }.
        from(Time.utc(2000)).
        to(Time.utc(3000))
    end

    it "updates character's refresh token" do
      character = create(:character, refresh_token: "old")

      stub_oauth_token(refresh_token: "new")

      expect { Eve::RenewAccessToken.new(character).call }.
        to change { character.reload.refresh_token }.
        from("old").
        to("new")
    end

    context "when forced and token not expired yet" do
      it "does update character" do
        character = build(:character)

        stub_oauth_token
        allow(character).to receive(:token_expired?).and_return(false)
        allow(character).to receive(:update!)

        Eve::RenewAccessToken.new(character, force: true).call

        expect(character).to have_received(:update!)
      end
    end

    context "when not forced and token not expired yet" do
      it "does not update character" do
        character = build(:character)

        allow(character).to receive(:token_expired?).and_return(false)
        allow(character).to receive(:update!)

        Eve::RenewAccessToken.new(character, force: false).call

        expect(character).not_to have_received(:update!)
      end
    end

    context "with an invalid refresh token" do
      it "voids character's refresh token" do
        character = build(:character)

        refresh_token = stub_oauth_token
        oauth_error = stub_oauth_error("invalid_token")

        allow(character).to receive(:void_refresh_token!)
        allow(refresh_token).to receive(:refresh!).and_raise(oauth_error)

        expect { Eve::RenewAccessToken.new(character, force: true).call }.
          to raise_error(OAuth2::Error) do
          expect(character).to have_received(:void_refresh_token!)
        end
      end
    end

    def stub_oauth_error(code)
      OAuth2::Error.allocate.tap do |e|
        e.instance_variable_set(:@code, code)
      end
    end

    def stub_oauth_token(token: nil, expires_at: nil, refresh_token: nil)
      instance_spy(
        OAuth2::AccessToken,
        token: token || "0xNEW",
        expires_at: expires_at || 1.day.from_now,
        refresh_token: refresh_token || "0xNEW_REFRESH",
      ).tap do |t|
        allow(t).to receive(:refresh!).and_return(t)
        allow(OAuth2::AccessToken).to receive(:from_hash).and_return(t)
      end
    end
  end
end
