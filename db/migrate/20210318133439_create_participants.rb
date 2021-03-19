class CreateParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :participants do |t|
      t.integer :user_id
      t.string :taggable_type
      t.integer :taggable_id

      t.timestamps
    end
  end
end
