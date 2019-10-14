class CreateBudgetBallotConfirmations < ActiveRecord::Migration
  def change
    create_table :budget_ballot_confirmations do |t|
      t.string :phone_number

      t.integer :group_id
      t.integer :ballot_id
      t.integer :budget_id
      t.integer :user_id

      t.integer :confirmed_by_user_id
      t.timestamp :confirmed_at
      t.string :confirmed_by_user_name

      t.integer :discarted_by_user_id
      t.timestamp :discarted_at
      t.string :discarted_by_user_name

      t.datetime :sms_sent_at
      t.text :ballot_summary

      t.timestamps null: false
    end
  end
end
