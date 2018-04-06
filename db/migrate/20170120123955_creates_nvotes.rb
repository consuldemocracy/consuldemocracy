class CreatesNvotes < ActiveRecord::Migration
  def change
    create_table "nvotes", force: :cascade do |t|
      t.integer  "user_id"
      t.integer  "poll_id"
      t.string   "voter_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.integer  "agora_id"
    end

    add_index "nvotes", ["deleted_at"], name: "index_nvotes_on_deleted_at"
  end
end
