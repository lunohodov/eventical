class AddCharacterOwnerHashToEventsAndAccessTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :access_tokens, :character_owner_hash, :text
    add_column :events, :character_owner_hash, :text

    add_index :access_tokens, :character_owner_hash
    add_index :events, :character_owner_hash
    add_index :events, %i[uid character_owner_hash], unique: true
  end
end
