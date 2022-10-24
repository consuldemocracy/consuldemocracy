class CreateLegislationAnnotations < ActiveRecord::Migration[4.2]
  def change
    create_table :legislation_annotations do |t|
      t.string :quote
      t.text :ranges
      t.text :text

      t.references :legislation_draft_version, index: true
      t.references :user, index: true

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end
  end
end
