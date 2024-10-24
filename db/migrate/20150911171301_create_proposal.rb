class CreateProposal < ActiveRecord::Migration[4.2]
  def change
    create_table :proposals do |t|
      t.string   "title", limit: 80
      t.text     "description"
      t.string   "question"
      t.string   "external_url"
      t.integer  "author_id"
      t.datetime "hidden_at"
      t.integer  "flags_count", default: 0
      t.datetime "ignored_flag_at"
      t.integer  "cached_votes_up",  default: 0
      t.integer  "comments_count",   default: 0
      t.datetime "confirmed_hide_at"
      t.integer  "hot_score",        limit: 8, default: 0
      t.integer  "confidence_score", default: 0

      t.timestamps null: false
    end
  end
end
