class RemoveObsoleteAttributesFromVolunteerPolls < ActiveRecord::Migration
  def change
    remove_column :volunteer_polls, :availability_week
    remove_column :volunteer_polls, :availability_weekend
  end
end
