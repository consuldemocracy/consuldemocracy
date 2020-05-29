class RenameLegislationsToLegacyLegislations < ActiveRecord::Migration[4.2]
  def change
    rename_table :legislations, :legacy_legislations
    rename_column :annotations, :legislation_id, :legacy_legislation_id
  end
end
