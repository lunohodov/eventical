class AddEventOwnerCategoriesToAccessTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :access_tokens, :event_owner_categories, :string, array: true
  end
end
