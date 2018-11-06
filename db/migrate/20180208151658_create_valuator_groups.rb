class CreateValuatorGroups < ActiveRecord::Migration
  def change
    create_table :valuator_groups do |t|
      t.string :name
    end
  end
end
