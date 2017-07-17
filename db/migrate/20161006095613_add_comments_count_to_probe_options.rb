class AddCommentsCountToProbeOptions < ActiveRecord::Migration
  def change
    add_column :probe_options, :comments_count, :integer, default: 0, null: false
  end
end
