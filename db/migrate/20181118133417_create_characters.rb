class CreateCharacters < ActiveRecord::Migration[5.2]
  def change
    create_table :characters do |t|
      t.bigint :uid, null: false
      t.string :name, null: false
      t.string :token
      t.string :refresh_token
      t.datetime :token_expires_at
      t.string :scopes
      t.string :token_type
      t.string :owner_hash

      t.timestamps

      t.index :uid, unique: true
    end
  end
end
