class AddOwnerToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :owner_uid, :bigint, null: true
    add_column :events, :owner_category, :string, null: true
    add_column :events, :owner_name, :string, null: true
  end
end
