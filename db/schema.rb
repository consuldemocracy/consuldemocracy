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

ActiveRecord::Schema.define(version: 20190103132925) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "pg_trgm"

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "action"
    t.integer  "actionable_id"
    t.string   "actionable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["actionable_id", "actionable_type"], name: "index_activities_on_actionable_id_and_actionable_type", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "admin_notification_translations", force: :cascade do |t|
    t.integer  "admin_notification_id", null: false
    t.string   "locale",                null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "title"
    t.text     "body"
  end

  add_index "admin_notification_translations", ["admin_notification_id"], name: "index_admin_notification_translations_on_admin_notification_id", using: :btree
  add_index "admin_notification_translations", ["locale"], name: "index_admin_notification_translations_on_locale", using: :btree

  create_table "admin_notifications", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.string   "link"
    t.string   "segment_recipient"
    t.integer  "recipients_count"
    t.date     "sent_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "administrators", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "administrators", ["user_id"], name: "index_administrators_on_user_id", using: :btree

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
    t.string   "ip"
  end

  add_index "ahoy_events", ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
  add_index "ahoy_events", ["time"], name: "index_ahoy_events_on_time", using: :btree
  add_index "ahoy_events", ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
  add_index "ahoy_events", ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree

  create_table "annotations", force: :cascade do |t|
    t.string   "quote"
    t.text     "ranges"
    t.text     "text"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "user_id"
    t.integer  "legacy_legislation_id"
  end

  add_index "annotations", ["legacy_legislation_id"], name: "index_annotations_on_legacy_legislation_id", using: :btree
  add_index "annotations", ["user_id"], name: "index_annotations_on_user_id", using: :btree

  create_table "banner_sections", force: :cascade do |t|
    t.integer  "banner_id"
    t.integer  "web_section_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "banner_translations", force: :cascade do |t|
    t.integer  "banner_id",   null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "title"
    t.text     "description"
  end

  add_index "banner_translations", ["banner_id"], name: "index_banner_translations_on_banner_id", using: :btree
  add_index "banner_translations", ["locale"], name: "index_banner_translations_on_locale", using: :btree

  create_table "banners", force: :cascade do |t|
    t.string   "title",            limit: 80
    t.string   "description"
    t.string   "target_url"
    t.date     "post_started_at"
    t.date     "post_ended_at"
    t.datetime "hidden_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "background_color"
    t.text     "font_color"
  end

  add_index "banners", ["hidden_at"], name: "index_banners_on_hidden_at", using: :btree

  create_table "budget_ballot_lines", force: :cascade do |t|
    t.integer  "ballot_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "budget_id"
    t.integer  "group_id"
    t.integer  "heading_id"
  end

  add_index "budget_ballot_lines", ["ballot_id", "investment_id"], name: "index_budget_ballot_lines_on_ballot_id_and_investment_id", unique: true, using: :btree
  add_index "budget_ballot_lines", ["ballot_id"], name: "index_budget_ballot_lines_on_ballot_id", using: :btree
  add_index "budget_ballot_lines", ["investment_id"], name: "index_budget_ballot_lines_on_investment_id", using: :btree

  create_table "budget_ballots", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_content_blocks", force: :cascade do |t|
    t.integer  "heading_id"
    t.text     "body"
    t.string   "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "budget_content_blocks", ["heading_id"], name: "index_budget_content_blocks_on_heading_id", using: :btree

  create_table "budget_groups", force: :cascade do |t|
    t.integer "budget_id"
    t.string  "name",                 limit: 50
    t.string  "slug"
    t.integer "max_votable_headings",            default: 1
  end

  add_index "budget_groups", ["budget_id"], name: "index_budget_groups_on_budget_id", using: :btree

  create_table "budget_headings", force: :cascade do |t|
    t.integer "group_id"
    t.string  "name",                 limit: 50
    t.integer "price",                limit: 8
    t.integer "population"
    t.string  "slug"
    t.boolean "allow_custom_content",            default: false
    t.text    "latitude"
    t.text    "longitude"
  end

  add_index "budget_headings", ["group_id"], name: "index_budget_headings_on_group_id", using: :btree

  create_table "budget_investment_milestone_translations", force: :cascade do |t|
    t.integer  "budget_investment_milestone_id", null: false
    t.string   "locale",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "title"
    t.text     "description"
  end

  add_index "budget_investment_milestone_translations", ["budget_investment_milestone_id"], name: "index_6770e7675fe296cf87aa0fd90492c141b5269e0b", using: :btree
  add_index "budget_investment_milestone_translations", ["locale"], name: "index_budget_investment_milestone_translations_on_locale", using: :btree

  create_table "budget_investment_milestones", force: :cascade do |t|
    t.integer  "investment_id"
    t.string   "title",            limit: 80
    t.text     "description"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "publication_date"
    t.integer  "status_id"
  end

  add_index "budget_investment_milestones", ["status_id"], name: "index_budget_investment_milestones_on_status_id", using: :btree

  create_table "budget_investment_statuses", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "hidden_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "budget_investment_statuses", ["hidden_at"], name: "index_budget_investment_statuses_on_hidden_at", using: :btree

  create_table "budget_investments", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "administrator_id"
    t.string   "title"
    t.text     "description"
    t.string   "external_url"
    t.integer  "price",                            limit: 8
    t.string   "feasibility",                      limit: 15, default: "undecided"
    t.text     "price_explanation"
    t.text     "unfeasibility_explanation"
    t.boolean  "valuation_finished",                          default: false
    t.integer  "valuator_assignments_count",                  default: 0
    t.integer  "price_first_year",                 limit: 8
    t.string   "duration"
    t.datetime "hidden_at"
    t.integer  "cached_votes_up",                             default: 0
    t.integer  "comments_count",                              default: 0
    t.integer  "confidence_score",                            default: 0,           null: false
    t.integer  "physical_votes",                              default: 0
    t.tsvector "tsv"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.integer  "heading_id"
    t.string   "responsible_name"
    t.integer  "budget_id"
    t.integer  "group_id"
    t.boolean  "selected",                                    default: false
    t.string   "location"
    t.string   "organization_name"
    t.datetime "unfeasible_email_sent_at"
    t.integer  "ballot_lines_count",                          default: 0
    t.integer  "previous_heading_id"
    t.boolean  "winner",                                      default: false
    t.boolean  "incompatible",                                default: false
    t.integer  "community_id"
    t.boolean  "visible_to_valuators",                        default: false
    t.integer  "valuator_group_assignments_count",            default: 0
    t.datetime "confirmed_hide_at"
    t.datetime "ignored_flag_at"
    t.integer  "flags_count",                                 default: 0
  end

  add_index "budget_investments", ["administrator_id"], name: "index_budget_investments_on_administrator_id", using: :btree
  add_index "budget_investments", ["author_id"], name: "index_budget_investments_on_author_id", using: :btree
  add_index "budget_investments", ["community_id"], name: "index_budget_investments_on_community_id", using: :btree
  add_index "budget_investments", ["heading_id"], name: "index_budget_investments_on_heading_id", using: :btree
  add_index "budget_investments", ["tsv"], name: "index_budget_investments_on_tsv", using: :gin

  create_table "budget_phases", force: :cascade do |t|
    t.integer  "budget_id"
    t.integer  "next_phase_id"
    t.string   "kind",                         null: false
    t.text     "summary"
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "enabled",       default: true
  end

  add_index "budget_phases", ["ends_at"], name: "index_budget_phases_on_ends_at", using: :btree
  add_index "budget_phases", ["kind"], name: "index_budget_phases_on_kind", using: :btree
  add_index "budget_phases", ["next_phase_id"], name: "index_budget_phases_on_next_phase_id", using: :btree
  add_index "budget_phases", ["starts_at"], name: "index_budget_phases_on_starts_at", using: :btree

  create_table "budget_reclassified_votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "investment_id"
    t.string   "reason"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "budget_valuator_assignments", force: :cascade do |t|
    t.integer  "valuator_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "budget_valuator_assignments", ["investment_id"], name: "index_budget_valuator_assignments_on_investment_id", using: :btree

