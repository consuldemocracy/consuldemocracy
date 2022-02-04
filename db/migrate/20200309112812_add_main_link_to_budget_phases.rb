class AddMainLinkToBudgetPhases < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_phases, :main_link_url, :string
    add_column :budget_phases, :main_button_url, :string
    add_column :budget_phase_translations, :main_link_text, :string
    add_column :budget_phase_translations, :main_button_text, :string
  end
end
