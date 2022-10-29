class CreateAuditLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :audit_logs do |t|
      t.belongs_to :auditable, polymorphic: true, index: true
      t.belongs_to :character, null: true, index: true

      t.text :action, index: true, null: false
      t.text :details

      t.timestamps
    end
  end
end
