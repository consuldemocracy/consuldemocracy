class RecreatedColumnRelatedContentsFlagsCount < ActiveRecord::Migration
  def change
    unless !column_exists? :related_contents, :times_reported
      remove_column :related_contents, :times_reported
    end

    unless column_exists? :related_contents, :flags_count
      add_column :related_contents, :flags_count, :integer, default: 0
    end
  end
end
