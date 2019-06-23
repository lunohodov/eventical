class AddUniquenessOnCharacterIdEventUidToEvents < ActiveRecord::Migration[5.2]
  def change
    add_index :events, %i[character_id uid], unique: true
  end
end
