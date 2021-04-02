class CreateAnalyticsCounters < ActiveRecord::Migration[6.1]
  def change
    create_table :analytics_counters do |t|
      t.belongs_to :owner, polymorphic: true, index: true

      t.string :topic, null: false, index: true
      t.bigint :value, null: false, default: 0

      t.timestamps
    end

    add_index :analytics_counters, %i[owner_id owner_type topic], unique: true, name: "analytics_counters_owner_and_topic"
  end
end
