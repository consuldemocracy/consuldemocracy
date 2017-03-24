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

ActiveRecord::Schema.define(version: 20170324101716) do

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
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.integer  "legislation_id"
  end

  add_index "annotations", ["legislation_id"], name: "index_annotations_on_legislation_id", using: :btree
  add_index "annotations", ["user_id"], name: "index_annotations_on_user_id", using: :btree

  create_table "banners", force: :cascade do |t|
    t.string   "title",           limit: 80
    t.string   "description"
    t.string   "target_url"
    t.string   "style"
    t.string   "image"
    t.date     "post_started_at"
    t.date     "post_ended_at"
    t.datetime "hidden_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
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

  add_index "budget_ballot_lines", ["ballot_id"], name: "index_budget_ballot_lines_on_ballot_id", using: :btree
  add_index "budget_ballot_lines", ["investment_id"], name: "index_budget_ballot_lines_on_investment_id", using: :btree

  create_table "budget_ballots", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_groups", force: :cascade do |t|
    t.integer "budget_id"
    t.string  "name",      limit: 50
  end

  add_index "budget_groups", ["budget_id"], name: "index_budget_groups_on_budget_id", using: :btree

  create_table "budget_headings", force: :cascade do |t|
    t.integer "group_id"
    t.string  "name",     limit: 50
    t.integer "price",    limit: 8
  end

  add_index "budget_headings", ["group_id"], name: "index_budget_headings_on_group_id", using: :btree

  create_table "budget_investments", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "administrator_id"
    t.string   "title"
    t.text     "description"
    t.string   "external_url"
    t.integer  "price",                      limit: 8
    t.string   "feasibility",                limit: 15, default: "undecided"
    t.text     "price_explanation"
    t.text     "unfeasibility_explanation"
    t.text     "internal_comments"
    t.boolean  "valuation_finished",                    default: false
    t.integer  "valuator_assignments_count",            default: 0
    t.integer  "price_first_year",           limit: 8
    t.string   "duration"
    t.datetime "hidden_at"
    t.integer  "cached_votes_up",                       default: 0
    t.integer  "comments_count",                        default: 0
    t.integer  "confidence_score",                      default: 0,           null: false
    t.integer  "physical_votes",                        default: 0
    t.tsvector "tsv"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "heading_id"
    t.string   "responsible_name"
    t.integer  "budget_id"
    t.integer  "group_id"
    t.boolean  "selected",                              default: false
    t.string   "location"
    t.string   "organization_name"
    t.datetime "unfeasible_email_sent_at"
  end

  add_index "budget_investments", ["administrator_id"], name: "index_budget_investments_on_administrator_id", using: :btree
  add_index "budget_investments", ["author_id"], name: "index_budget_investments_on_author_id", using: :btree
  add_index "budget_investments", ["heading_id"], name: "index_budget_investments_on_heading_id", using: :btree
  add_index "budget_investments", ["tsv"], name: "index_budget_investments_on_tsv", using: :gin

  create_table "budget_valuator_assignments", force: :cascade do |t|
    t.integer  "valuator_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "budget_valuator_assignments", ["investment_id"], name: "index_budget_valuator_assignments_on_investment_id", using: :btree

  create_table "budgets", force: :cascade do |t|
    t.string   "name",                          limit: 30
    t.string   "currency_symbol",               limit: 10
    t.string   "phase",                         limit: 40, default: "accepting"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.text     "description_accepting"
    t.text     "description_reviewing"
    t.text     "description_selecting"
    t.text     "description_valuating"
    t.text     "description_balloting"
    t.text     "description_reviewing_ballots"
    t.text     "description_finished"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.string   "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "hidden_at"
    t.integer  "flags_count",        default: 0
    t.datetime "ignored_flag_at"
    t.integer  "moderator_id"
    t.integer  "administrator_id"
    t.integer  "cached_votes_total", default: 0
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
    t.datetime "confirmed_hide_at"
    t.string   "ancestry"
    t.integer  "confidence_score",   default: 0, null: false
  end

  add_index "comments", ["ancestry"], name: "index_comments_on_ancestry", using: :btree
  add_index "comments", ["cached_votes_down"], name: "index_comments_on_cached_votes_down", using: :btree
  add_index "comments", ["cached_votes_total"], name: "index_comments_on_cached_votes_total", using: :btree
  add_index "comments", ["cached_votes_up"], name: "index_comments_on_cached_votes_up", using: :btree
  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["hidden_at"], name: "index_comments_on_hidden_at", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "debates", force: :cascade do |t|
    t.string   "title",                        limit: 80
    t.text     "description"
    t.integer  "author_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "visit_id"
    t.datetime "hidden_at"
    t.integer  "flags_count",                             default: 0
    t.datetime "ignored_flag_at"
    t.integer  "cached_votes_total",                      default: 0
    t.integer  "cached_votes_up",                         default: 0
    t.integer  "cached_votes_down",                       default: 0
    t.integer  "comments_count",                          default: 0
    t.datetime "confirmed_hide_at"
    t.integer  "cached_anonymous_votes_total",            default: 0
    t.integer  "cached_votes_score",                      default: 0
    t.integer  "hot_score",                    limit: 8,  default: 0
    t.integer  "confidence_score",                        default: 0
    t.integer  "geozone_id"
    t.tsvector "tsv"
    t.datetime "featured_at"
  end

  add_index "debates", ["author_id", "hidden_at"], name: "index_debates_on_author_id_and_hidden_at", using: :btree
  add_index "debates", ["author_id"], name: "index_debates_on_author_id", using: :btree
  add_index "debates", ["cached_votes_down"], name: "index_debates_on_cached_votes_down", using: :btree
  add_index "debates", ["cached_votes_score"], name: "index_debates_on_cached_votes_score", using: :btree
  add_index "debates", ["cached_votes_total"], name: "index_debates_on_cached_votes_total", using: :btree
  add_index "debates", ["cached_votes_up"], name: "index_debates_on_cached_votes_up", using: :btree
  add_index "debates", ["confidence_score"], name: "index_debates_on_confidence_score", using: :btree
  add_index "debates", ["geozone_id"], name: "index_debates_on_geozone_id", using: :btree
  add_index "debates", ["hidden_at"], name: "index_debates_on_hidden_at", using: :btree
  add_index "debates", ["hot_score"], name: "index_debates_on_hot_score", using: :btree
  add_index "debates", ["title"], name: "index_debates_on_title", using: :btree
  add_index "debates", ["tsv"], name: "index_debates_on_tsv", using: :gin

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "direct_messages", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "failed_census_calls", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "document_number"
    t.string   "document_type"
    t.date     "date_of_birth"
    t.string   "postal_code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "district_code"
  end

  add_index "failed_census_calls", ["user_id"], name: "index_failed_census_calls_on_user_id", using: :btree

  create_table "flags", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "flaggable_type"
    t.integer  "flaggable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["flaggable_type", "flaggable_id"], name: "index_flags_on_flaggable_type_and_flaggable_id", using: :btree
  add_index "flags", ["user_id", "flaggable_type", "flaggable_id"], name: "access_inappropiate_flags", using: :btree
  add_index "flags", ["user_id"], name: "index_flags_on_user_id", using: :btree

  create_table "geozones", force: :cascade do |t|
    t.string   "name"
    t.string   "html_map_coordinates"
    t.string   "external_code"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "census_code"
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "legislations", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "tries",        default: 0
    t.datetime "locked_until", default: '2000-01-01 00:01:01', null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "locks", ["user_id"], name: "index_locks_on_user_id", using: :btree

  create_table "managers", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "managers", ["user_id"], name: "index_managers_on_user_id", using: :btree

  create_table "moderators", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "moderators", ["user_id"], name: "index_moderators_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.integer  "counter",         default: 1
    t.datetime "emailed_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",             limit: 60
    t.datetime "verified_at"
    t.datetime "rejected_at"
    t.string   "responsible_name", limit: 60
  end

  add_index "organizations", ["user_id"], name: "index_organizations_on_user_id", using: :btree

  create_table "proposal_notifications", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "author_id"
    t.integer  "proposal_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "proposals", force: :cascade do |t|
    t.string   "title",               limit: 80
    t.text     "description"
    t.string   "question"
    t.string   "external_url"
    t.integer  "author_id"
    t.datetime "hidden_at"
    t.integer  "flags_count",                    default: 0
    t.datetime "ignored_flag_at"
    t.integer  "cached_votes_up",                default: 0
    t.integer  "comments_count",                 default: 0
    t.datetime "confirmed_hide_at"
    t.integer  "hot_score",           limit: 8,  default: 0
    t.integer  "confidence_score",               default: 0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "responsible_name",    limit: 60
    t.text     "summary"
    t.string   "video_url"
    t.tsvector "tsv"
    t.integer  "geozone_id"
    t.datetime "retired_at"
    t.string   "retired_reason"
    t.text     "retired_explanation"
  end

  add_index "proposals", ["author_id", "hidden_at"], name: "index_proposals_on_author_id_and_hidden_at", using: :btree
  add_index "proposals", ["author_id"], name: "index_proposals_on_author_id", using: :btree
  add_index "proposals", ["cached_votes_up"], name: "index_proposals_on_cached_votes_up", using: :btree
  add_index "proposals", ["confidence_score"], name: "index_proposals_on_confidence_score", using: :btree
  add_index "proposals", ["geozone_id"], name: "index_proposals_on_geozone_id", using: :btree
  add_index "proposals", ["hidden_at"], name: "index_proposals_on_hidden_at", using: :btree
  add_index "proposals", ["hot_score"], name: "index_proposals_on_hot_score", using: :btree
  add_index "proposals", ["question"], name: "index_proposals_on_question", using: :btree
  add_index "proposals", ["summary"], name: "index_proposals_on_summary", using: :btree
  add_index "proposals", ["title"], name: "index_proposals_on_title", using: :btree
  add_index "proposals", ["tsv"], name: "index_proposals_on_tsv", using: :gin

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
  end

  add_index "settings", ["key"], name: "index_settings_on_key", using: :btree

  create_table "signature_sheets", force: :cascade do |t|
    t.integer  "signable_id"
    t.string   "signable_type"
    t.text     "document_numbers"
    t.boolean  "processed",        default: false
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "signatures", force: :cascade do |t|
    t.integer  "signature_sheet_id"
    t.integer  "user_id"
    t.string   "document_number"
    t.boolean  "verified",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_customization_content_blocks", force: :cascade do |t|
    t.string   "name"
    t.string   "locale"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "site_customization_content_blocks", ["name", "locale"], name: "index_site_customization_content_blocks_on_name_and_locale", unique: true, using: :btree

  create_table "site_customization_images", force: :cascade do |t|
    t.string   "name",               null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "site_customization_images", ["name"], name: "index_site_customization_images_on_name", unique: true, using: :btree

  create_table "site_customization_pages", force: :cascade do |t|
    t.string   "slug",                                 null: false
    t.string   "title",                                null: false
    t.string   "subtitle"
    t.text     "content"
    t.boolean  "more_info_flag"
    t.boolean  "print_content_flag"
    t.string   "status",             default: "draft"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "spending_proposals", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "author_id"
    t.string   "external_url"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "geozone_id"
    t.integer  "price",                       limit: 8
    t.boolean  "feasible"
    t.string   "association_name"
    t.text     "price_explanation"
    t.text     "feasible_explanation"
    t.text     "internal_comments"
    t.boolean  "valuation_finished",                     default: false
    t.text     "explanations_log"
    t.integer  "administrator_id"
    t.integer  "valuation_assignments_count",            default: 0
    t.integer  "price_first_year",            limit: 8
    t.string   "time_scope"
    t.datetime "unfeasible_email_sent_at"
    t.integer  "cached_votes_up",                        default: 0
    t.tsvector "tsv"
    t.string   "responsible_name",            limit: 60
    t.integer  "physical_votes",                         default: 0
  end

  add_index "spending_proposals", ["author_id"], name: "index_spending_proposals_on_author_id", using: :btree
  add_index "spending_proposals", ["geozone_id"], name: "index_spending_proposals_on_geozone_id", using: :btree
  add_index "spending_proposals", ["tsv"], name: "index_spending_proposals_on_tsv", using: :gin

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",                     limit: 40
    t.integer "taggings_count",                      default: 0
    t.boolean "featured",                            default: false
    t.integer "debates_count",                       default: 0
    t.integer "proposals_count",                     default: 0
    t.integer "spending_proposals_count",            default: 0
    t.string  "kind"
    t.integer "budget/investments_count",            default: 0
  end

  add_index "tags", ["debates_count"], name: "index_tags_on_debates_count", using: :btree
  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["proposals_count"], name: "index_tags_on_proposals_count", using: :btree
  add_index "tags", ["spending_proposals_count"], name: "index_tags_on_spending_proposals_count", using: :btree

  create_table "tolk_locales", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_locales", ["name"], name: "index_tolk_locales_on_name", unique: true, using: :btree

  create_table "tolk_phrases", force: :cascade do |t|
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", force: :cascade do |t|
    t.integer  "phrase_id"
    t.integer  "locale_id"
    t.text     "text"
    t.text     "previous_text"
    t.boolean  "primary_updated", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_translations", ["phrase_id", "locale_id"], name: "index_tolk_translations_on_phrase_id_and_locale_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                     default: ""
    t.string   "encrypted_password",                        default: "",                    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                             default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "email_on_comment",                          default: false
    t.boolean  "email_on_comment_reply",                    default: false
    t.string   "phone_number",                   limit: 30
    t.string   "official_position"
    t.integer  "official_level",                            default: 0
    t.datetime "hidden_at"
    t.string   "sms_confirmation_code"
    t.string   "username",                       limit: 60
    t.string   "document_number"
    t.string   "document_type"
    t.datetime "residence_verified_at"
    t.string   "email_verification_token"
    t.datetime "verified_at"
    t.string   "unconfirmed_phone"
    t.string   "confirmed_phone"
    t.datetime "letter_requested_at"
    t.datetime "confirmed_hide_at"
    t.string   "letter_verification_code"
    t.integer  "failed_census_calls_count",                 default: 0
    t.datetime "level_two_verified_at"
    t.string   "erase_reason"
    t.datetime "erased_at"
    t.boolean  "public_activity",                           default: true
    t.boolean  "newsletter",                                default: true
    t.integer  "notifications_count",                       default: 0
    t.boolean  "registering_with_oauth",                    default: false
    t.string   "locale"
    t.string   "oauth_email"
    t.integer  "geozone_id"
    t.string   "redeemable_code"
    t.string   "gender",                         limit: 10
    t.datetime "date_of_birth"
    t.boolean  "email_on_proposal_notification",            default: true
    t.boolean  "email_digest",                              default: true
    t.boolean  "email_on_direct_message",                   default: true
    t.boolean  "official_position_badge",                   default: false
    t.datetime "password_changed_at",                       default: '2016-11-02 13:51:14', null: false
    t.boolean  "created_from_signature",                    default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["geozone_id"], name: "index_users_on_geozone_id", using: :btree
  add_index "users", ["hidden_at"], name: "index_users_on_hidden_at", using: :btree
  add_index "users", ["password_changed_at"], name: "index_users_on_password_changed_at", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "valuation_assignments", force: :cascade do |t|
    t.integer  "valuator_id"
    t.integer  "spending_proposal_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "valuators", force: :cascade do |t|
    t.integer "user_id"
    t.string  "description"
    t.integer "spending_proposals_count", default: 0
    t.integer "budget_investments_count", default: 0
  end

  add_index "valuators", ["user_id"], name: "index_valuators_on_user_id", using: :btree

  create_table "verified_users", force: :cascade do |t|
    t.string   "document_number"
    t.string   "document_type"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "verified_users", ["document_number"], name: "index_verified_users_on_document_number", using: :btree
  add_index "verified_users", ["email"], name: "index_verified_users_on_email", using: :btree
  add_index "verified_users", ["phone"], name: "index_verified_users_on_phone", using: :btree

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["started_at"], name: "index_visits_on_started_at", using: :btree
  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "signature_id"
  end

  add_index "votes", ["signature_id"], name: "index_votes_on_signature_id", using: :btree
  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "administrators", "users"
  add_foreign_key "annotations", "legislations"
  add_foreign_key "annotations", "users"
  add_foreign_key "failed_census_calls", "users"
  add_foreign_key "flags", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "locks", "users"
  add_foreign_key "managers", "users"
  add_foreign_key "moderators", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "organizations", "users"
  add_foreign_key "users", "geozones"
  add_foreign_key "valuators", "users"
end
