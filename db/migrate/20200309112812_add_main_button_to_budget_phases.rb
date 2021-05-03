class AddMainButtonToBudgetPhases < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_phases, :main_button_text, :string
    add_column :budget_phases, :main_button_url, :string
  end
end
