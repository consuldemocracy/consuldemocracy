class AddProposalsTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :proposal_translations do |t|
      t.integer :proposal_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :description
      t.text :summary
      t.text :retired_explanation

      t.index :locale
      t.index :proposal_id
    end
  end
end
