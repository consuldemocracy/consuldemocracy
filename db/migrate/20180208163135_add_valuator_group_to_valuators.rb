class AddValuatorGroupToValuators < ActiveRecord::Migration
  def change
    add_column :valuators, :valuator_group_id, :integer
  end
end
