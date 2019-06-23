class RemoveUniqueIndexFromEventsForUid < ActiveRecord::Migration[5.2]
  def up
    remove_index :events, :uid
  end

  def down
    if can_enforce_uniqueness?
      add_index :events, :uid, unique: true
    else
      raise ActiveRecord::IrreversibleMigration
    end
  end

  private

  def can_enforce_uniqueness?
    !Event.group(:uid).having("count(uid) > 1").exists?
  end
end
