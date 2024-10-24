class AddMainLinkToBudgetPhases < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_phase_translations, :main_link_text, :string
    add_column :budget_phases, :main_link_url, :string
  end
end
