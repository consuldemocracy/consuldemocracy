class AddPublicationDateToMilestones < ActiveRecord::Migration
  def up
    change_table :budget_investment_milestones do |t|
      t.datetime :publication_date
    end
  end

  def down
    change_table :budget_investment_milestones do |t|
      t.remove :publication_date
    end
  end
end
