class ChangeRelatedContentTimesReportedColumn < ActiveRecord::Migration
  def change
    rename_column :related_contents, :times_reported, :flags_count
  end
end
