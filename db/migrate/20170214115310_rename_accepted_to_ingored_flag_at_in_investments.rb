class RenameAcceptedToIngoredFlagAtInInvestments < ActiveRecord::Migration
  def change
    rename_column :budget_investments, :accepted_at, :ignored_flag_at
  end
end
