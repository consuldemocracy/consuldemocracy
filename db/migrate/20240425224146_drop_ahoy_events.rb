class DropAhoyEvents < ActiveRecord::Migration[7.0]
  def change
    drop_table :ahoy_events, id: :uuid, default: nil do |t|
      t.uuid :visit_id
      t.integer :user_id
      t.string :name
      t.jsonb :properties
      t.datetime :time, precision: nil
      t.string :ip

      t.index [:name, :time]
      t.index [:time]
      t.index [:user_id]
      t.index [:visit_id]
    end
  end
end
