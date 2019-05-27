class CreatePollBooths < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_booths do |t|
      t.string :name
      t.integer :poll_id
    end
  end
end
