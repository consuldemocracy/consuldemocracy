class CreateStatsVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :stats_versions do |t|
      t.references :process, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
