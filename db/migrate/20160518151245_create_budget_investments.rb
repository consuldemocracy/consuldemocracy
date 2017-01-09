class CreateBudgetInvestments < ActiveRecord::Migration
  def change
    create_table :budget_investments do |t|

      t.references "geozone"

      t.integer  "author_id", index: true
      t.integer  "administrator_id", index: true

      t.string   "title"
      t.text     "description"
      t.string   "external_url"

      t.integer  "price", limit: 8
      t.string   "feasibility", default: "undecided", limit: 15
      t.text     "price_explanation"
      t.text     "unfeasibility_explanation"
      t.text     "internal_comments"
      t.boolean  "valuation_finished", default: false
      t.integer  "valuation_assignments_count", default: 0
      t.integer  "price_first_year", limit: 8
      t.string   "duration"

      t.datetime "hidden_at"
      t.integer  "cached_votes_up", default: 0
      t.integer  "comments_count", default: 0
      t.integer  "confidence_score", default: 0,     null: false
      t.integer  "physical_votes", default: 0

      t.tsvector "tsv"

      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index :budget_investments, :tsv, using: "gin"
  end
end
