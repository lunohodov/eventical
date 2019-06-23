class AddRefreshTokenVoidedAtToCharacters < ActiveRecord::Migration[5.2]
  def change
    add_column :characters, :refresh_token_voided_at, :datetime, default: nil

    add_index :characters, :refresh_token_voided_at
  end
end
