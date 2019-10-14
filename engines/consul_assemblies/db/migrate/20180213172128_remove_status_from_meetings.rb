class RemoveStatusFromMeetings < ActiveRecord::Migration
  def change
  	remove_column :consul_assemblies_meetings, :status
  end
end
