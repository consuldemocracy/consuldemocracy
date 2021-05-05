class CreatePollParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_participants do |t|
      t.references :poll, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
