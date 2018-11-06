class AddTimeReportedToRelatedContent < ActiveRecord::Migration
  def change
    add_column :related_contents, :times_reported, :integer, default: 0
  end
end
