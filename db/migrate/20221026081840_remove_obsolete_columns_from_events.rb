class RemoveObsoleteColumnsFromEvents < ActiveRecord::Migration[6.1]
  def up
    remove_columns :events,
      :character_id,
      :details_updated_at,
      :owner_category,
      :owner_name,
      :owner_uid
  end

  def down
    say <<-MSG.strip_heredoc
      NOTE:

        This migration is not reversible. We can recreate the columns
        but can't restore the data.

        To restore to a working state in development, checkout the commit prior
        to this migration and run `rake db:reset dev:prime`.

    MSG

    raise ActiveRecord::IrreversibleMigration
  end
end
