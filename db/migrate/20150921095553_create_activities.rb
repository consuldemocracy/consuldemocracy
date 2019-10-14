class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id
      t.string :action
      t.belongs_to :actionable, polymorphic: true
      t.timestamps
    end

    add_index :activities, [:actionable_id, :actionable_type]
    add_index :activities, :user_id
  end
end
