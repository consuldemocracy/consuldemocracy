class AddSummaryToBudgetInvestments < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        add_column :budget_investments, :summary, :text unless column_exists?(:budget_investments, :summary)
      end

      dir.down do
        if column_exists?(:budget_investments, :summary)
          remove_column :budget_investments, :summary
        else
          say "Column :summary does not exist in budget_investments table, skipping removal"
        end
      end
    end
  end
end
