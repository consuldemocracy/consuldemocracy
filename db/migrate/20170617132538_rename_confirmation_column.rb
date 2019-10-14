class RenameConfirmationColumn < ActiveRecord::Migration
  def change
    rename_column :budget_ballot_confirmations,:confirmed_by_user_name, :confirmed_by_username
  end
end
