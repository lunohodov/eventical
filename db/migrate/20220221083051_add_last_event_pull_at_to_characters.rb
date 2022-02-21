class AddLastEventPullAtToCharacters < ActiveRecord::Migration[6.1]
  def change
    add_column :characters, :last_event_pull_at, :datetime, index: true, default: nil
  end
end
