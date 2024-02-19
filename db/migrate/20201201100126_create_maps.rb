class CreateMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :maps do |t|
      t.integer :budget_id, index: true

      t.timestamps
    end
  end
end
