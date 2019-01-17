require "rails_helper"
require "securerandom"

describe CharacterAccessToken do
  describe "#expired?" do
    it "is delegated to character" do
      character = spy

      CharacterAccessToken.new(character).expired?

      expect(character).to have_received(:token_expired?)
    end
  end

  describe "#expires_at?" do
    it "is delegated to character" do
      character = spy

      CharacterAccessToken.new(character).expires_at?(Date.current)

      expect(character).to have_received(:token_expires_at?).with(Date.current)
    end
  end

  describe "#refresh!" do
    def stub_renew_token_result(token: nil, refresh_token: nil, expires_at: nil, backend:) # rubocop:disable Metrics/LineLength
      double(
        token: token || SecureRandom.uuid,
        refresh_token: refresh_token || SecureRandom.uuid,
        expires_at: expires_at || 1.day.from_now,
      ).tap do |result|
        allow(backend).to receive(:renew_access_token!).and_return(result)
      end
    end

    it "requests a new token from ESI" do
      character = create(:character, refresh_token: "one")
      esi = class_double(Eve::Esi)

      stub_renew_token_result(backend: esi)

      CharacterAccessToken.new(character, esi: esi).refresh!

      expect(esi).to have_received(:renew_access_token!).with("one")
    end

    it "updates character's token" do
      character = create(:character, token: "alpha")
      esi = class_double(Eve::Esi)

      stub_renew_token_result(
        token: "oscar",
        refresh_token: "oscar_refresh",
        expires_at: 1,
        backend: esi,
      )

      CharacterAccessToken.new(character, esi: esi).refresh!

      character.reload

      expect(character.token).to eq("oscar")
      expect(character.refresh_token).to eq("oscar_refresh")
      expect(character.token_expires_at).to eq(Time.at(1).in_time_zone)
    end

    it "returns the new token" do
      character = create(:character, token: "alpha")
      esi = class_double(Eve::Esi)

      stub_renew_token_result(
        token: "oscar",
        refresh_token: "oscar_refresh",
        expires_at: 1,
        backend: esi,
      )

      actual = CharacterAccessToken.new(character, esi: esi).refresh!

      expect(actual).to eq("oscar")
    end

    context "with an ESI error" do
      it "keeps character token unchanged" do
        character = create(:character, token: "alpha")
        esi = class_double(Eve::Esi)

        allow(esi).to receive(:renew_access_token!).
          and_raise(OAuth2::Error.allocate)

        expect do
          CharacterAccessToken.new(character, esi: esi).refresh!
        end.to raise_error(OAuth2::Error) do |_|
          expect(character.token).to eq("alpha")
          expect(character.reload.token).to eq("alpha")
        end
      end
    end
  end
end
