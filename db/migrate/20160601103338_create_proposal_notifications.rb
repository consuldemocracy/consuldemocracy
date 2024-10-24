class CreateProposalNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :proposal_notifications do |t|
      t.string :title
      t.text :body
      t.integer :author_id
      t.integer :proposal_id

      t.timestamps null: false
    end
  end
end
