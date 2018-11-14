class MakeInvestmentMilestonesPolymorphic < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.references :milestoneable, polymorphic: true
      t.string   "title", limit: 80
      t.text     "description"
      t.datetime "publication_date"

      t.references :status, index: true

      t.timestamps null: false
    end

    reversible do |change|
      change.up do
        Milestone.create_translation_table!({
          title: :string,
          description: :text
        })
      end

      change.down do
        Milestone.drop_translation_table!
      end
    end
  end
end
