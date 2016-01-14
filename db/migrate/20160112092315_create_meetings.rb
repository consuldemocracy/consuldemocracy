class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.string :title
      t.text :description
      t.string :address
      t.date :held_at
      t.time :start_at
      t.time :end_at
      t.integer :author_id

      t.timestamps null: false
    end
  end
end
