class DropStatsVersions < ActiveRecord::Migration[7.0]
  def change
    drop_table :stats_versions, id: :serial do |t|
      t.string :process_type
      t.integer :process_id
      t.datetime :created_at, precision: nil, null: false
      t.datetime :updated_at, precision: nil, null: false

      t.index ["process_type", "process_id"], name: "index_stats_versions_on_process_type_and_process_id"
    end
  end
end
