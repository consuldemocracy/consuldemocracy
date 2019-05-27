class CreateLegislationDraftVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :legislation_draft_versions do |t|
      t.references :legislation_process, index: true, foreign_key: true
      t.string :title
      t.text :changelog
      t.string :status, index: true, default: :draft
      t.boolean :final_version, default: false
      t.text :body

      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end
  end
end
