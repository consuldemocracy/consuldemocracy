class AddTimeReportedToRelatedContent < ActiveRecord::Migration[4.2]
  def change
    add_column :related_contents, :times_reported, :integer, default: 0
  end
end
