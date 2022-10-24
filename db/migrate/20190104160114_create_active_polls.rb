class CreateActivePolls < ActiveRecord::Migration[4.2]
  def change
    create_table :active_polls do |t|
      t.timestamps null: false
    end
  end
end
