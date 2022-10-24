class RenameColumnsWithSlashCharacters < ActiveRecord::Migration[5.1]
  def change
    change_table :tags do |t|
      t.rename :"budget/investments_count", :budget_investments_count
      t.rename :"legislation/proposals_count", :legislation_proposals_count
      t.rename :"legislation/processes_count", :legislation_processes_count
    end
  end
end
