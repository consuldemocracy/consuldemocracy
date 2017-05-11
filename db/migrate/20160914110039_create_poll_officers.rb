class CreatePollOfficers < ActiveRecord::Migration
  def change
    create_table :poll_officers do |t|
      t.integer :user_id
    end
  end
end
