# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180126092530) do

  create_table "consul_assemblies_assemblies", force: :cascade do |t|
    t.string   "name",                null: false
    t.string   "general_description"
    t.string   "scope_description"
    t.integer  "geozone_id",          null: false
    t.string   "about_venue"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "assembly_type_id"
  end

  add_index "consul_assemblies_assemblies", ["geozone_id"], name: "index_consul_assemblies_assemblies_on_geozone_id"

  create_table "consul_assemblies_assembly_types", force: :cascade do |t|
    t.string   "name",             null: false
    t.string   "description"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "assembly_type_id"
  end

  create_table "consul_assemblies_meetings", force: :cascade do |t|
    t.string   "title",                                    null: false
    t.string   "description"
    t.string   "summary"
    t.string   "status",                                   null: false
    t.string   "about_venue"
    t.integer  "assembly_id",                              null: false
    t.integer  "followers_count",              default: 0
    t.integer  "comments_count",               default: 0
    t.datetime "close_accepting_proposals_at"
    t.datetime "scheduled_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "published_at"
    t.string   "attachment"
    t.string   "attachment_url"
    t.integer  "user_id"
  end

  add_index "consul_assemblies_meetings", ["assembly_id"], name: "index_consul_assemblies_meetings_on_assembly_id"

  create_table "consul_assemblies_proposals", force: :cascade do |t|
    t.integer  "meeting_id",                     null: false
    t.string   "title",                          null: false
    t.text     "description"
    t.integer  "user_id"
    t.boolean  "accepted"
    t.boolean  "terms_of_service"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "conclusion"
    t.boolean  "is_previous_meeting_acceptance"
    t.integer  "position"
  end

  add_index "consul_assemblies_proposals", ["meeting_id"], name: "index_consul_assemblies_proposals_on_meeting_id"

end
