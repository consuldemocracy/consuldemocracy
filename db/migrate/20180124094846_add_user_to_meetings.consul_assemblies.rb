# This migration comes from consul_assemblies (originally 20180124093530)
class AddUserToMeetings < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_meetings, :user_id, :integer
  end
end
