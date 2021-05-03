class AddNameToBudgetPhases < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        Budget::Phase.add_translation_fields! name: :string
      end

      dir.down do
        remove_column :budget_phase_translations, :name
      end
    end
  end
end
