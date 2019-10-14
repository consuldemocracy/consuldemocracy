class AddUserToMeetings < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_meetings, :user_id, :integer
  end
end
