class TranslateBudgetPhaseMainLinkUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_phase_translations, :main_link_url, :string
    remove_column :budget_phases, :main_link_url, :string
  end
end
