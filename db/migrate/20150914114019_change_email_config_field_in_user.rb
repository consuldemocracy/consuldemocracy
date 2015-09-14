class ChangeEmailConfigFieldInUser < ActiveRecord::Migration
  def change
    rename_column :users, :email_on_debate_comment, :email_on_comment
  end
end
