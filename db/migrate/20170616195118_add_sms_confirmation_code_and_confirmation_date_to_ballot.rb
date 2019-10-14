class AddSmsConfirmationCodeAndConfirmationDateToBallot < ActiveRecord::Migration
  def change
    add_column :budget_ballot_confirmations, :sms_confirmation_code, :string, null: nil

    add_column :budget_ballot_confirmations, :sms_code_sent_at, :datetime
    add_column :budget_ballot_confirmations, :sms_code_sent_by_username, :string
    add_column :budget_ballot_confirmations, :sms_code_sent_by_user_id, :integer
    add_column :budget_ballot_confirmations, :sms_code_sending_error, :text

    add_column :budget_ballot_confirmations,:created_by_username, :string
    add_column :budget_ballot_confirmations,:created_by_user_id, :integer


    rename_column :budget_ballot_confirmations,:discarted_by_user_name, :discarted_by_username
  end
end
