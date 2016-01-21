class AddCloseFieldsToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :close_report, :text
    add_column :meetings, :closed_at, :datetime
  end
end
