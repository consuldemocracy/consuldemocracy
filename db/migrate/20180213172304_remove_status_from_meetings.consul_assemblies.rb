# This migration comes from consul_assemblies (originally 20180213172128)
class RemoveStatusFromMeetings < ActiveRecord::Migration
  def change
  	remove_column :consul_assemblies_meetings, :status
  end
end
