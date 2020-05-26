class CreateLegislationPeopleProposalsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :legislation_people_proposals, force: :cascade do |t|
      t.integer  "legislation_process_id"
      t.string   "title", limit: 80
      t.text     "description"
      t.string   "question"
      t.integer  "author_id"
      t.datetime "hidden_at"
      t.integer  "flags_count", default: 0
      t.datetime "ignored_flag_at"
      t.integer  "cached_votes_up", default: 0
      t.integer  "comments_count", default: 0
      t.datetime "confirmed_hide_at"
      t.integer  "hot_score", limit: 8, default: 0
      t.integer  "confidence_score", default: 0
      t.string   "responsible_name", limit: 60
      t.text     "summary"
      t.string   "video_url"
      t.tsvector "tsv"
      t.datetime "retired_at"
      t.string   "retired_reason"
      t.text     "retired_explanation"
      t.integer  "community_id"
      t.timestamps null: false
      t.integer  "cached_votes_total", default: 0
      t.integer  "cached_votes_down", default: 0
      t.boolean  "selected"
      t.boolean  "validated"
      t.integer  "cached_votes_score", default: 0
    end
    add_index "legislation_people_proposals", ["cached_votes_score"], name: "index_legislation_people_proposals_on_cached_votes_score", using: :btree
  end
end
