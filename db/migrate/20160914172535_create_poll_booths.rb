class CreatePollBooths < ActiveRecord::Migration
  def change
    create_table :poll_booths do |t|
      t.string :name
      t.integer :poll_id
    end
  end
end
