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

ActiveRecord::Schema.define(version: 20170428111355) do

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
    t.index ["actionable_id", "actionable_type"], name: "index_activities_on_actionable_id_and_actionable_type", using: :btree
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "administrators", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_administrators_on_user_id", using: :btree
  end

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
    t.string   "ip"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
    t.index ["time"], name: "index_ahoy_events_on_time", using: :btree
    t.index ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree
  end

  create_table "annotations", force: :cascade do |t|
    t.string   "quote"
    t.text     "ranges"
    t.text     "text"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.integer  "legislation_id"
    t.index ["legislation_id"], name: "index_annotations_on_legislation_id", using: :btree
    t.index ["user_id"], name: "index_annotations_on_user_id", using: :btree
  end

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
    t.index ["hidden_at"], name: "index_banners_on_hidden_at", using: :btree
  end

  create_table "budget_ballot_lines", force: :cascade do |t|
    t.integer  "ballot_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "budget_id"
    t.integer  "group_id"
    t.integer  "heading_id"
    t.index ["ballot_id"], name: "index_budget_ballot_lines_on_ballot_id", using: :btree
    t.index ["investment_id"], name: "index_budget_ballot_lines_on_investment_id", using: :btree
  end

  create_table "budget_ballots", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_groups", force: :cascade do |t|
    t.integer "budget_id"
    t.string  "name",      limit: 50
    t.index ["budget_id"], name: "index_budget_groups_on_budget_id", using: :btree
  end

  create_table "budget_headings", force: :cascade do |t|
    t.integer "group_id"
    t.string  "name",     limit: 50
    t.bigint  "price"
    t.index ["group_id"], name: "index_budget_headings_on_group_id", using: :btree
  end

  create_table "budget_investments", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "administrator_id"
    t.string   "title"
    t.text     "description"
    t.string   "external_url"
    t.bigint   "price"
    t.string   "feasibility",                limit: 15, default: "undecided"
    t.text     "price_explanation"
    t.text     "unfeasibility_explanation"
    t.text     "internal_comments"
    t.boolean  "valuation_finished",                    default: false
    t.integer  "valuator_assignments_count",            default: 0
    t.bigint   "price_first_year"
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
    t.integer  "ballot_lines_count",                    default: 0
    t.index ["administrator_id"], name: "index_budget_investments_on_administrator_id", using: :btree
    t.index ["author_id"], name: "index_budget_investments_on_author_id", using: :btree
    t.index ["heading_id"], name: "index_budget_investments_on_heading_id", using: :btree
    t.index ["tsv"], name: "index_budget_investments_on_tsv", using: :gin
  end

  create_table "budget_valuator_assignments", force: :cascade do |t|
    t.integer  "valuator_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["investment_id"], name: "index_budget_valuator_assignments_on_investment_id", using: :btree
  end

  create_table "budgets", force: :cascade do |t|
    t.string   "name",                          limit: 80
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
    t.index ["ancestry"], name: "index_comments_on_ancestry", using: :btree
    t.index ["cached_votes_down"], name: "index_comments_on_cached_votes_down", using: :btree
    t.index ["cached_votes_total"], name: "index_comments_on_cached_votes_total", using: :btree
    t.index ["cached_votes_up"], name: "index_comments_on_cached_votes_up", using: :btree
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["hidden_at"], name: "index_comments_on_hidden_at", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

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
    t.bigint   "hot_score",                               default: 0
    t.integer  "confidence_score",                        default: 0
    t.integer  "geozone_id"
    t.tsvector "tsv"
    t.datetime "featured_at"
    t.index ["author_id", "hidden_at"], name: "index_debates_on_author_id_and_hidden_at", using: :btree
    t.index ["author_id"], name: "index_debates_on_author_id", using: :btree
    t.index ["cached_votes_down"], name: "index_debates_on_cached_votes_down", using: :btree
    t.index ["cached_votes_score"], name: "index_debates_on_cached_votes_score", using: :btree
    t.index ["cached_votes_total"], name: "index_debates_on_cached_votes_total", using: :btree
    t.index ["cached_votes_up"], name: "index_debates_on_cached_votes_up", using: :btree
    t.index ["confidence_score"], name: "index_debates_on_confidence_score", using: :btree
    t.index ["geozone_id"], name: "index_debates_on_geozone_id", using: :btree
    t.index ["hidden_at"], name: "index_debates_on_hidden_at", using: :btree
    t.index ["hot_score"], name: "index_debates_on_hot_score", using: :btree
    t.index ["title"], name: "index_debates_on_title", using: :btree
    t.index ["tsv"], name: "index_debates_on_tsv", using: :gin
  end

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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

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
    t.integer  "year_of_birth"
    t.integer  "poll_officer_id"
    t.index ["user_id"], name: "index_failed_census_calls_on_user_id", using: :btree
  end

  create_table "flags", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "flaggable_type"
    t.integer  "flaggable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["flaggable_type", "flaggable_id"], name: "index_flags_on_flaggable_type_and_flaggable_id", using: :btree
    t.index ["user_id", "flaggable_type", "flaggable_id"], name: "access_inappropiate_flags", using: :btree
    t.index ["user_id"], name: "index_flags_on_user_id", using: :btree
  end

  create_table "geozones", force: :cascade do |t|
    t.string   "name"
    t.string   "html_map_coordinates"
    t.string   "external_code"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "census_code"
  end

  create_table "geozones_polls", force: :cascade do |t|
    t.integer "geozone_id"
    t.integer "poll_id"
    t.index ["geozone_id"], name: "index_geozones_polls_on_geozone_id", using: :btree
    t.index ["poll_id"], name: "index_geozones_polls_on_poll_id", using: :btree
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

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
    t.index ["user_id"], name: "index_locks_on_user_id", using: :btree
  end

  create_table "managers", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_managers_on_user_id", using: :btree
  end

  create_table "moderators", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_moderators_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.integer  "counter",         default: 1
    t.datetime "emailed_at"
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "organizations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",             limit: 60
    t.datetime "verified_at"
    t.datetime "rejected_at"
    t.string   "responsible_name", limit: 60
    t.index ["user_id"], name: "index_organizations_on_user_id", using: :btree
  end

  create_table "poll_answers", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "author_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_id"], name: "index_poll_answers_on_author_id", using: :btree
    t.index ["question_id", "answer"], name: "index_poll_answers_on_question_id_and_answer", using: :btree
    t.index ["question_id"], name: "index_poll_answers_on_question_id", using: :btree
  end

  create_table "poll_booth_assignments", force: :cascade do |t|
    t.integer  "booth_id"
    t.integer  "poll_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booth_id"], name: "index_poll_booth_assignments_on_booth_id", using: :btree
    t.index ["poll_id"], name: "index_poll_booth_assignments_on_poll_id", using: :btree
  end

  create_table "poll_booths", force: :cascade do |t|
    t.string "name"
    t.string "location"
  end

  create_table "poll_final_recounts", force: :cascade do |t|
    t.integer  "booth_assignment_id"
    t.integer  "officer_assignment_id"
    t.integer  "count"
    t.text     "count_log",                 default: ""
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.text     "officer_assignment_id_log", default: ""
    t.date     "date",                                   null: false
    t.index ["booth_assignment_id"], name: "index_poll_final_recounts_on_booth_assignment_id", using: :btree
    t.index ["officer_assignment_id"], name: "index_poll_final_recounts_on_officer_assignment_id", using: :btree
  end

  create_table "poll_null_results", force: :cascade do |t|
    t.integer "author_id"
    t.integer "amount"
    t.string  "origin"
    t.date    "date"
    t.integer "booth_assignment_id"
    t.integer "officer_assignment_id"
    t.text    "amount_log",                default: ""
    t.text    "officer_assignment_id_log", default: ""
    t.text    "author_id_log",             default: ""
    t.index ["booth_assignment_id"], name: "index_poll_null_results_on_booth_assignment_id", using: :btree
    t.index ["officer_assignment_id"], name: "index_poll_null_results_on_officer_assignment_id", using: :btree
  end

  create_table "poll_officer_assignments", force: :cascade do |t|
    t.integer  "booth_assignment_id"
    t.integer  "officer_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.date     "date",                                null: false
    t.boolean  "final",               default: false
    t.string   "user_data_log",       default: ""
    t.index ["booth_assignment_id"], name: "index_poll_officer_assignments_on_booth_assignment_id", using: :btree
    t.index ["officer_id", "date"], name: "index_poll_officer_assignments_on_officer_id_and_date", using: :btree
    t.index ["officer_id"], name: "index_poll_officer_assignments_on_officer_id", using: :btree
  end

  create_table "poll_officers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "failed_census_calls_count", default: 0
    t.index ["user_id"], name: "index_poll_officers_on_user_id", using: :btree
  end

  create_table "poll_partial_results", force: :cascade do |t|
    t.integer "question_id"
    t.integer "author_id"
    t.string  "answer"
    t.integer "amount"
    t.string  "origin"
    t.date    "date"
    t.integer "booth_assignment_id"
    t.integer "officer_assignment_id"
    t.text    "amount_log",                default: ""
    t.text    "officer_assignment_id_log", default: ""
    t.text    "author_id_log",             default: ""
    t.index ["answer"], name: "index_poll_partial_results_on_answer", using: :btree
    t.index ["author_id"], name: "index_poll_partial_results_on_author_id", using: :btree
    t.index ["booth_assignment_id", "date"], name: "index_poll_partial_results_on_booth_assignment_id_and_date", using: :btree
    t.index ["origin"], name: "index_poll_partial_results_on_origin", using: :btree
    t.index ["question_id"], name: "index_poll_partial_results_on_question_id", using: :btree
  end

  create_table "poll_questions", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "poll_id"
    t.integer  "author_id"
    t.string   "author_visible_name"
    t.string   "title"
    t.string   "valid_answers"
    t.text     "description"
    t.integer  "comments_count"
    t.datetime "hidden_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.tsvector "tsv"
    t.index ["author_id"], name: "index_poll_questions_on_author_id", using: :btree
    t.index ["poll_id"], name: "index_poll_questions_on_poll_id", using: :btree
    t.index ["proposal_id"], name: "index_poll_questions_on_proposal_id", using: :btree
    t.index ["tsv"], name: "index_poll_questions_on_tsv", using: :gin
  end

  create_table "poll_recounts", force: :cascade do |t|
    t.integer  "booth_assignment_id"
    t.integer  "officer_assignment_id"
    t.integer  "count"
    t.text     "count_log",                 default: ""
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.date     "date",                                   null: false
    t.text     "officer_assignment_id_log", default: ""
    t.index ["booth_assignment_id"], name: "index_poll_recounts_on_booth_assignment_id", using: :btree
    t.index ["officer_assignment_id"], name: "index_poll_recounts_on_officer_assignment_id", using: :btree
  end

  create_table "poll_voters", force: :cascade do |t|
    t.string   "document_number"
    t.string   "document_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "poll_id",               null: false
    t.integer  "booth_assignment_id"
    t.integer  "age"
    t.string   "gender"
    t.integer  "geozone_id"
    t.integer  "answer_id"
    t.integer  "officer_assignment_id"
    t.integer  "user_id"
    t.index ["booth_assignment_id"], name: "index_poll_voters_on_booth_assignment_id", using: :btree
    t.index ["document_number"], name: "index_poll_voters_on_document_number", using: :btree
    t.index ["officer_assignment_id"], name: "index_poll_voters_on_officer_assignment_id", using: :btree
    t.index ["poll_id", "document_number", "document_type"], name: "doc_by_poll", using: :btree
    t.index ["poll_id"], name: "index_poll_voters_on_poll_id", using: :btree
    t.index ["user_id"], name: "index_poll_voters_on_user_id", using: :btree
  end

  create_table "poll_white_results", force: :cascade do |t|
    t.integer "author_id"
    t.integer "amount"
    t.string  "origin"
    t.date    "date"
    t.integer "booth_assignment_id"
    t.integer "officer_assignment_id"
    t.text    "amount_log",                default: ""
    t.text    "officer_assignment_id_log", default: ""
    t.text    "author_id_log",             default: ""
    t.index ["booth_assignment_id"], name: "index_poll_white_results_on_booth_assignment_id", using: :btree
    t.index ["officer_assignment_id"], name: "index_poll_white_results_on_officer_assignment_id", using: :btree
  end

  create_table "polls", force: :cascade do |t|
    t.string   "name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "published",          default: false
    t.boolean  "geozone_restricted", default: false
    t.index ["starts_at", "ends_at"], name: "index_polls_on_starts_at_and_ends_at", using: :btree
  end

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
    t.bigint   "hot_score",                      default: 0
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
    t.index ["author_id", "hidden_at"], name: "index_proposals_on_author_id_and_hidden_at", using: :btree
    t.index ["author_id"], name: "index_proposals_on_author_id", using: :btree
    t.index ["cached_votes_up"], name: "index_proposals_on_cached_votes_up", using: :btree
    t.index ["confidence_score"], name: "index_proposals_on_confidence_score", using: :btree
    t.index ["geozone_id"], name: "index_proposals_on_geozone_id", using: :btree
    t.index ["hidden_at"], name: "index_proposals_on_hidden_at", using: :btree
    t.index ["hot_score"], name: "index_proposals_on_hot_score", using: :btree
    t.index ["question"], name: "index_proposals_on_question", using: :btree
    t.index ["summary"], name: "index_proposals_on_summary", using: :btree
    t.index ["title"], name: "index_proposals_on_title", using: :btree
    t.index ["tsv"], name: "index_proposals_on_tsv", using: :gin
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.index ["key"], name: "index_settings_on_key", using: :btree
  end

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
    t.index ["name", "locale"], name: "index_site_customization_content_blocks_on_name_and_locale", unique: true, using: :btree
  end

  create_table "site_customization_images", force: :cascade do |t|
    t.string   "name",               null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["name"], name: "index_site_customization_images_on_name", unique: true, using: :btree
  end

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
    t.bigint   "price"
    t.boolean  "feasible"
    t.string   "association_name"
    t.text     "price_explanation"
    t.text     "feasible_explanation"
    t.text     "internal_comments"
    t.boolean  "valuation_finished",                     default: false
    t.text     "explanations_log"
    t.integer  "administrator_id"
    t.integer  "valuation_assignments_count",            default: 0
    t.bigint   "price_first_year"
    t.string   "time_scope"
    t.datetime "unfeasible_email_sent_at"
    t.integer  "cached_votes_up",                        default: 0
    t.tsvector "tsv"
    t.string   "responsible_name",            limit: 60
    t.integer  "physical_votes",                         default: 0
    t.index ["author_id"], name: "index_spending_proposals_on_author_id", using: :btree
    t.index ["geozone_id"], name: "index_spending_proposals_on_geozone_id", using: :btree
    t.index ["tsv"], name: "index_spending_proposals_on_tsv", using: :gin
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name",                     limit: 40
    t.integer "taggings_count",                      default: 0
    t.boolean "featured",                            default: false
    t.integer "debates_count",                       default: 0
    t.integer "proposals_count",                     default: 0
    t.integer "spending_proposals_count",            default: 0
    t.string  "kind"
    t.integer "budget/investments_count",            default: 0
    t.index ["debates_count"], name: "index_tags_on_debates_count", using: :btree
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
    t.index ["proposals_count"], name: "index_tags_on_proposals_count", using: :btree
    t.index ["spending_proposals_count"], name: "index_tags_on_spending_proposals_count", using: :btree
  end

  create_table "tolk_locales", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_tolk_locales_on_name", unique: true, using: :btree
  end

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
    t.index ["phrase_id", "locale_id"], name: "index_tolk_translations_on_phrase_id_and_locale_id", unique: true, using: :btree
  end

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
    t.integer  "failed_email_digests_count",                default: 0
    t.text     "former_users_data_log",                     default: ""
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["geozone_id"], name: "index_users_on_geozone_id", using: :btree
    t.index ["hidden_at"], name: "index_users_on_hidden_at", using: :btree
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", using: :btree
  end

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
    t.index ["user_id"], name: "index_valuators_on_user_id", using: :btree
  end

  create_table "verified_users", force: :cascade do |t|
    t.string   "document_number"
    t.string   "document_type"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["document_number"], name: "index_verified_users_on_document_number", using: :btree
    t.index ["email"], name: "index_verified_users_on_email", using: :btree
    t.index ["phone"], name: "index_verified_users_on_phone", using: :btree
  end

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
    t.index ["started_at"], name: "index_visits_on_started_at", using: :btree
    t.index ["user_id"], name: "index_visits_on_user_id", using: :btree
  end

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
    t.index ["signature_id"], name: "index_votes_on_signature_id", using: :btree
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree
  end

  add_foreign_key "administrators", "users"
  add_foreign_key "annotations", "legislations"
  add_foreign_key "annotations", "users"
  add_foreign_key "failed_census_calls", "poll_officers"
  add_foreign_key "failed_census_calls", "users"
  add_foreign_key "flags", "users"
  add_foreign_key "geozones_polls", "polls"
  add_foreign_key "identities", "users"
  add_foreign_key "locks", "users"
  add_foreign_key "managers", "users"
  add_foreign_key "moderators", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "organizations", "users"
  add_foreign_key "poll_answers", "poll_questions", column: "question_id"
  add_foreign_key "poll_booth_assignments", "polls"
  add_foreign_key "poll_final_recounts", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_final_recounts", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_null_results", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_null_results", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_officer_assignments", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_partial_results", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_partial_results", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_partial_results", "poll_questions", column: "question_id"
  add_foreign_key "poll_questions", "polls"
  add_foreign_key "poll_recounts", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_recounts", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_voters", "polls"
  add_foreign_key "poll_white_results", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_white_results", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "users", "geozones"
  add_foreign_key "valuators", "users"
end
