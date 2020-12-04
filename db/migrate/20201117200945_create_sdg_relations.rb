class CreateSDGRelations < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_relations do |t|
      t.references :related_sdg, polymorphic: true
      t.references :relatable, polymorphic: true

      t.index [:related_sdg_id, :related_sdg_type, :relatable_id, :relatable_type], name: "sdg_relations_unique", unique: true

      t.timestamps
    end
  end
end
