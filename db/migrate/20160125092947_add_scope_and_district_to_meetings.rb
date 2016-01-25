class AddScopeAndDistrictToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :scope, :string, default: "district"
    add_column :meetings, :district, :integer
  end
end
