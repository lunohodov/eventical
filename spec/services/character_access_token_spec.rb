require "rails_helper"

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
    it "requests a new token from ESI" do
      character = create(:character)
      esi = class_double(Eve::Esi)

      allow(esi).to receive(:renew_access_token!).and_return("oscar")

      CharacterAccessToken.new(character, esi: esi).refresh!

      expect(esi).to have_received(:renew_access_token!).
        with(character.refresh_token)
    end

    it "updates character's token" do
      character = create(:character, token: "alpha")
      esi = class_double(Eve::Esi)

      allow(esi).to receive(:renew_access_token!).and_return("bravo")

      expect { CharacterAccessToken.new(character, esi: esi).refresh! }.
        to change { character.reload.token }.from("alpha").to("bravo")
    end

    it "returns the new token" do
      character = create(:character, token: "alpha")
      esi = class_double(Eve::Esi)

      allow(esi).to receive(:renew_access_token!).and_return("bravo")

      actual = CharacterAccessToken.new(character, esi: esi).refresh!

      expect(actual).to eq("bravo")
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
