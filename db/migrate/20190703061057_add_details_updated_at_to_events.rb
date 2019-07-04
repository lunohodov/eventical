class AddDetailsUpdatedAtToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :details_updated_at, :datetime, default: nil

    add_index :events, :details_updated_at
  end
end
