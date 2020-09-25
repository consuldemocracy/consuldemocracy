class AddResultTextToBudgets < ActiveRecord::Migration[5.0]
  def change
    add_column :budgets, :result_text, :text
  end
end
