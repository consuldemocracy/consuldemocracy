class CreateDesignEvents < ActiveRecord::Migration
  def change
    create_table :design_events do |t|
      t.string :name
      t.datetime :starts_at
      t.string :place
      t.integer :pax

      t.timestamps null: false
    end
  end
end
