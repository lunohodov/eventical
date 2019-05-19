class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.string :owner_hash, null: false
      t.string :time_zone, null: true, default: nil

      t.timestamps

      t.index :owner_hash, unique: true
    end
  end
end
