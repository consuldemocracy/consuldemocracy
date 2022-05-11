class AddInvestmentAnswer < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_investment_answers do |t|
      t.references :budget
      t.references :investment
      t.references :budget_question
      t.string :text, null: false, index: true
    end
  end
end
