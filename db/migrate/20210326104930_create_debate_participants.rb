class CreateDebateParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :debate_participants do |t|
      t.references :user, foreign_key: true
      t.references :debate, foreign_key: true

      t.timestamps
    end
  end
end
