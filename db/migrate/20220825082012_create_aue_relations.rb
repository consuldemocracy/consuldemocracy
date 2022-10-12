class CreateAUERelations < ActiveRecord::Migration[5.2]
  def change
    create_table :aue_relations do |t|
      t.references :related_aue, polymorphic: true
      t.references :relatable, polymorphic: true

      t.index [:related_aue_id, :related_aue_type, :relatable_id, :relatable_type], name: "aue_relations_unique", unique: true

      t.timestamps
    end
  end
end
