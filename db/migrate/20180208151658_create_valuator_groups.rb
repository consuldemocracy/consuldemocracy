class CreateValuatorGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :valuator_groups do |t|
      t.string :name
    end
  end
end
