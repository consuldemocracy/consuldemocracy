class MakeInvestmentMilestonesPolymorphic < ActiveRecord::Migration[4.2]
  def change
    create_table :milestones, id: :serial do |t|
      t.string :milestoneable_type
      t.integer :milestoneable_id
      t.string   "title", limit: 80
      t.text     "description"
      t.datetime "publication_date"

      t.integer :status_id, index: true

      t.timestamps null: false
    end

    create_table :milestone_translations do |t|
      t.integer :milestone_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :description

      t.index :locale
      t.index :milestone_id
    end
  end
end
