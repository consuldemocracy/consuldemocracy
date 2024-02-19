class AddMainLinkToBudgetPhasesWhenUpgrading < ActiveRecord::Migration[5.0]
  def up
    unless column_exists? :budget_phases, :main_link_url
      add_column :budget_phases, :main_link_url, :string
    end

    unless column_exists? :budget_phase_translations, :main_link_text
      add_column :budget_phase_translations, :main_link_text, :string
    end
  end
end
