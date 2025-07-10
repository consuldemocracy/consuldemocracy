class ChangeRelatedContentTimesReportedColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :related_contents, :times_reported, :flags_count
  end
end
