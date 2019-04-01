class AddValuatorGroupToValuators < ActiveRecord::Migration[4.2]
  def change
    add_column :valuators, :valuator_group_id, :integer
  end
end
