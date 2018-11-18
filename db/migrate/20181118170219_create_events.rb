class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :character, index: true
      t.bigint :uid, null: false
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.string :importance
      t.string :response

      t.timestamps null: false

      t.index :uid, unique: true
    end
  end
end
